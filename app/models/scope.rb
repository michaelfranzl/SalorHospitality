module Scope
  def self.included(klass)
    klass.scope(:accessible_by, lambda { |user|
      if user.respond_to?(:company_id) and not user.company_id.nil?
        klass.where( :company_id => user.company_id )
      elsif user.respond_to?(:vendor_id) and not user.vendor_id.nil?
        klass.where( :vendor_id => user.vendor_id )
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
