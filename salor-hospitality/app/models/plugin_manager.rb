# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'net/http'

class PluginManager < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers
  include Base
  
  helper ApplicationHelper
  
  self.view_paths = "app/views/"
  
  attr_accessor :javascript_files, :stylesheet_files, :template_files, :image_files, :metas, :logger
  
  def initialize(vendor, user, params, request)
    @user                   = user
    @vendor                 = vendor
    @plugins                = @vendor.plugins.existing
    @context                = V8::Context.new
    @context['SH']          = self
    @context['Params']      = params
    @context['Request']     = request
    #@context['PLUGINS_BASE_URL']         = @group.urls[:plugins]
    @code = nil
    
    @javascript_files = {}
    @stylesheet_files = {}
    @template_files = {}
    @image_files = {}
    
    @metas = {}
    
    # Filters are organized by name, which will be an
    # array of filters which will be sorted by their priority
    # { :some_filter => [
    #       {:function => "my_callback"}
    #   ]
    # }
    @filters                = {}
    
    @actions                = {}
    
    @text = "(function() {\nvar plugins = {};\n"
    @plugins.existing.each do |plugin|
      log_action "PluginManager initializing #{ plugin.name }"
      
      _files = plugin.files
      plugin_file_name = nil
      @metas[plugin.name] = plugin.meta
      
      _files.each do |f|
        if f.match(/\.pl\.js$/) then
          plugin_file_name = File.join(plugin.full_path,f)
        elsif f.match(/\.js$/) then
          @javascript_files[plugin.name] ||= []
          @javascript_files[plugin.name] << f
        elsif f.match(/\.css$/) then
          @stylesheet_files[plugin.name] ||= []
          @stylesheet_files[plugin.name] << f
        elsif f.match(/\.svg$/) then
          @image_files[plugin.name] ||= []
          @image_files[plugin.name] << f
        elsif f.match(/\.html$/) then
          @template_files[plugin.name] ||= []
          @template_files[plugin.name] << f
        end
      end
      
      if plugin_file_name and File.exists? plugin_file_name
        log_action("Opening plugin file " + plugin_file_name)
        File.open(plugin_file_name,'r') do |f|
          @text += f.read
          self.add_filter("metafields_#{ plugin.name }", "#{ plugin.name }.metafields")
        end
      end
    end
    @text += "\n return plugins; \n})();\n"
    
    begin
      @code = @context.eval(@text)
    rescue => e
      annotated_js = @text.split("\n").map.with_index{|l, i| "#{ i + 1 }: #{ l }" }
      log_action "Code failed to evaluate: #{ e.inspect } \n\n #{ annotated_js.join("\n") }"
    end
  end
  
  def log_action_plugin(obj="",color=:grey_on_blue)
    from = self.class.to_s
    Base.log_action(from, "PLUGIN: #{ v8_object_to_hash(obj) }", color)
  end
  
  def log_action(txt="",color=:green)
    from = self.class.to_s
    Base.log_action(from, txt, color)
  end
  
  # requires present "metafields" function in the plugin file
  def get_meta_fields_for(plugin)
    fields = {}
    fields = apply_filter("metafields_" + plugin.name, fields)
    return fields
  end
  
  def debug_obj(obj) 
    obj.each do |k,v|
      puts k.inspect
      log_action "#{k} -> #{v}"   
    end
  end
  
  def priority_sort(arr)
    return arr.sort {|a,b|  b[:priority] <=> a[:priority]}
  end
  
  def add_filter(name,function, priority=0)
    @filters[name.to_sym] ||= []
    @filters[name.to_sym].push({:function => function, :priority => priority})
    @filters[name.to_sym] = priority_sort(@filters[name.to_sym])
  end

  def add_action(name, function, priority=0)
    @actions[name.to_sym] ||= []
    @actions[name.to_sym].push({:function => function, :priority => priority})
    @actions[name.to_sym] = priority_sort(@actions[name.to_sym])
  end

  def get_function_from(obj, path)
    if path.include? '.' then
      # I.E. The namespacing will be like this
      # my.obj.callback
      # so we split by . then reverse, then pop
      # then drill down to the callback function
      path = path.split('.').reverse
      first = path.pop
      function = obj[first]
      path.each do |fname|
        function = function[fname]
      end
    else
      function = obj[path]
    end
    return function

  end

  # Filters work more or less in the same way as WP.
  # You pass in an argument and run it through the filters
  # and then it is returned to you.
  def apply_filter(name, res, params=nil)
    log_action("Applying filter: " + name)
    
    if not @code
      log_action("No code, returning")
      return res
    end

    cvrt = nil
    cvrt = res.class
    if @filters[name.to_sym] then
      @filters[name.to_sym].each do |callback|
        begin
          function_name = callback[:function]
          
          function = get_function_from(@code,function_name)
          
          if not function then
            log_action "function #{callback[:function]} is not set."
          else
            res = function.methodcall(function, res, params)
          end
          
         rescue => e
           log_action("There was an error in the ACTION " + name + ": " + e.inspect)
           log_action e.backtrace.join("\n")
           msg = []
           msg << "There was an error in the ACTION #{ name }"
           msg << e.inspect
           msg << e.backtrace[0..2].join("\n")
           annotated_js = @text.split("\n").map.with_index{|l, i| "#{ i + 1 }: #{ l }" }
           msg << annotated_js.join("\n")
           return "<pre>#{ msg.join("\n") }</pre>"
        end
      end 
    end
    
    if cvrt == Array then
      narg = []
      res.each do |el|
        if el.is_a? V8::Object then
          el = v8_object_to_hash(el)
        end
        narg << el
      end
      res = narg
    elsif cvrt == Hash then
      res = v8_object_to_hash(res)
    end
    
    log_action("Filter #{name} done.")
    return res
  end

  
  def do_action(name, arg=nil)
    name = name.to_s
    log_action("Beginning ACTION " + name)
    #return '' if not @code
    content = ''
    if @actions[name.to_sym] then
      @actions[name.to_sym].each do |callback|
        log_action("Executing ACTION " + name)
        function_name = callback[:function]
        function = get_function_from(@code,function_name)
        
        if not function then
          log_action "function #{callback[:function]} is not set."
        else
          log_action("About to call ACTION " + name)
          begin
            tmp = function.methodcall(function, arg)
          rescue => e
            log_action("There was an error in the ACTION " + name + ": " + e.inspect)
            log_action e.backtrace.join("\n")
            msg = []
            msg << "There was an error in the ACTION #{ name }"
            msg << e.inspect
            msg << e.backtrace[0..2].join("\n")
            annotated_js = @text.split("\n").map.with_index{|l, i| "#{ i + 1 }: #{ l }" }
            msg << annotated_js.join("\n")
            return "<pre>#{ msg.join("\n") }</pre>"
          end
          log_action("Call to ACTION " + name + " completed")
          if tmp.class != String then
            log_action "Must return a string from an action"
          else
            log_action("ACTION returned: " + tmp[0..20])
            content += tmp
          end
        end
      end 
    else
      log_action("There are no ACTIONs")
    end
    log_action("ACTION COMPLETE")
    return content.html_safe
  end

#   def render_partial(name,locals)
#     vars = v8_object_to_hash(locals)
#     debug_obj(vars)
#     render( :partial => name, :locals => vars)
#   end

  def v8_object_to_hash(src_attrs)
    attrs = {}
    if src_attrs.kind_of? V8::Object then
      src_attrs.each do |k,v|
        k.gsub("'",'').gsub('"','')
        if v.kind_of? V8::Object then
          attrs[k.to_sym] = v8_object_to_hash(v)
        else
          attrs[k.to_sym] = v
        end
      end
      return attrs
    else
      return src_attrs
    end
  end
  
  # The following methods are utility functions and are exposed to the plugin V8 sandbox
  
  def get_meta(plugin_name, attr)
    return @metas[plugin_name][attr] if @metas[plugin_name]
  end
  
  def request_localhost(method, path, port, data={}, headers={}, user=nil, pass=nil)
    headers = self.v8_object_to_hash(headers)
    
    port = port.to_i
    
    if port < 3000 or port > 3010
      # for security reasons, we don't allow just any port on localhost. 10 different services should be more than enough.
      return "port out of range"
    end
    
    url = "http://localhost:#{ port }#{ path }"
    uri = URI.parse(url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 2
    if method == "post"
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(data)
    elsif method == "get"
      request = Net::HTTP::Get.new(uri.request_uri)
    end
    
    if user and pass then
      log_action "get_url: setting basic authentication"
      request.basic_auth(user,pass)
    end
    headers.each do |k,v|
      request[k] = v
    end
    log_action "get_url: starting request"
    
    begin
      response = http.request(request)
    rescue
      return nil
    end
    
    log_action "get_url: finished request."
    return response.body
  end

end