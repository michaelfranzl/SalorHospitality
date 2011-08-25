module Scope
  def self.included(klass)
    begin
      inst = klass.new
      klass.scope(:by_company, lambda { |*args|
         if inst.respond_to? :company_id
           return {:conditions => ["company_id = ? ", $COMPANY.id]} if $COMPANY
         end
      })
      klass.scope(:active, lambda { |*args|
         if inst.respond_to? :active
            return {:conditions => {:active => true}}
         end
      })
      klass.scope(:available, lambda { |*args|
         if inst.respond_to? :hidden
           return {:conditions => "hidden = false OR hidden IS NULL OR hidden = 0"}
         end
      })
      klass.scope(:scopied, lambda { |*args|
          klass.send(:by_company).active.available
      })
      rescue Exception => e
        puts "Something bad happend..."
      end
  end
end
