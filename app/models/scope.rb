# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Scope
  def self.included(klass)
    klass.scope(:accessible_by, lambda { |model|
      if model.respond_to?(:company_id) and not model.company_id.nil?
        klass.where( :company_id => model.company_id )
      elsif model.respond_to?(:vendor_id) and not model.vendor_id.nil?
        klass.where( :vendor_id => model.vendor_id )
      end
    })

    klass.scope(:of, lambda { |model|
      if model.class == Vendor
        klass.where(:vendor_id => model.id)
      elsif model.class == Company
        klass.where(:company_id => model.id)
      end
    })

    begin
    if klass.column_names.include? 'hidden'
      klass.scope(:existing, lambda { klass.where('hidden = FALSE OR hidden IS NULL') })
    end

    if klass.column_names.include? 'active'
      klass.scope(:active, lambda { klass.where('active = TRUE') })
    end

    if klass.column_names.include? 'position'
      klass.scope(:positioned, lambda { klass.order('position ASC') })
    end
    rescue
      # don't let migrations on an empty database fail
    end
  end
end
