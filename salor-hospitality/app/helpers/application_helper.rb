# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module ApplicationHelper
  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f  

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end

  def nest_image(object)
    object.tap do |o|
      if o.images.empty? then
        o.images.build
        o.images.first.image_type = 'logo' if o.class.name == 'Vendor' and o.images.first.image_type.nil?
      end
      if o.class.name == 'Vendor' and o.images.count < 2 then
        o.images.first.image_type = 'logo' if o.images.first.image_type.nil?
        o.images.build
        if o.images.first.image_type == 'logo'
          o.images.last.image_type = 'invoice_logo'
        else
          o.images.last.image_type = 'logo'
        end
      end
    end
  end
  
  def branding_override_style(type, name)
    return '' unless @current_vendor.branding and @current_vendor.branding[:override_styles]
    if type == :buttons
      override_name = @current_vendor.branding[:override_styles][:buttons][name]
      if override_name
        return "background-image: url(/assets/button_mobile_#{override_name});"
      else
        return ''
      end
    elsif type == :somethingelse
      # to be implemented
      return ''
    else
      return ''
    end
  end
  
  def mainmenu_entry(path, i18n_path, icon)
    link_to path do
      raw "<img src=\"/assets/icons/#{ icon }.svg\" /><br /><span>#{ t i18n_path }</span>"
    end
  end
end
