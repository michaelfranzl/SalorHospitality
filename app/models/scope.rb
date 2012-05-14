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
