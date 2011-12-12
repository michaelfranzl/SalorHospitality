module Scope
  def self.included(klass)
    klass.scope(:accessible_by, lambda { |user|
      if user.respond_to?(:company_id) and not user.company_id.nil?
        klass.where( :company_id => user.company_id )
      elsif user.respond_to?(:vendor_id) and not user.vendor_id.nil?
        klass.where( :vendor_id => user.vendor_id )
      end
    })

    klass.scope(:active_and_accessible_by, lambda { |user|
      if user.respond_to?(:company_id) and not user.company_id.nil?
        return :conditions => "company_id = #{ user.company_id } AND active = TRUE"
      elsif user.respond_to?(:vendor_id) and not user.vendor_id.nil?
        return :conditions => "vendor_id = #{ user.vendor_id } AND active = TRUE"
      end
    })

    klass.scope(:existing_and_accessible_by, lambda { |user|
      if user.respond_to?(:company_id) and not user.company_id.nil?
        return :conditions => "company_id = #{ user.company_id } AND (hidden = FALSE OR hidden IS NULL)"
      elsif user.respond_to?(:vendor_id) and not user.vendor_id.nil?
        return :conditions => "vendor_id = #{ user.vendor_id } AND (hidden = FALSE OR hidden IS NULL)"
      end
    })

    klass.scope(:existing, lambda { klass.where('hidden = FALSE OR hidden IS NULL') })
  end
end
