# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SalorApi
  @@_callbacks = []
  @@_used_names = []

  def self.add(hook,name,priority, &block)
    if not @@_used_names.include? name then
      @@_used_names << name
    else
      raise "SalorApi: Name #{name} already taken, choose another."
    end
    cb_object = { :hook => hook, :name => name, :priority => priority, :block => block}
    @@_callbacks << cb_object
  end

  def self.run(hook,args=nil)
    @@_callbacks.sort_by {|v| v[:priority]}.each do |cb_object|
      h = cb_object[:hook]
      if h.class == String then
        args = cb_object[:block].call(args) if h == hook
      elsif h.class == Regexp then
        args = cb_object[:block].call(args) if hook =~ h
      end
    end
    return args
  end
end
