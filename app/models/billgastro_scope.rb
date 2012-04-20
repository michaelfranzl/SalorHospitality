module BillgastroScope
  def self.included(klass)
    begin
       inst = klass.new # luckily this is only called once when the module is included.
       klass.scope(:existing, lambda { |*args|
         if inst.respond_to? :hidden
           return { :conditions => "`#{ inst.class.table_name}`.`hidden` = false or `#{ inst.class.table_name}`.`hidden` is null"}
         end
       })
       klass.scope(:invisible, lambda { |*args|
         if inst.respond_to? :hidden
           return {:conditions => "`#{ inst.class.table_name }`.`hidden` = true"}
         end
       })
       klass.scope(:by_user, lambda { |user|
          if inst.respond_to? :user_id then
            return {:conditions => ["`#{inst.class.table_name}`.`user_id` = ?", user.id]}
          end
       })
       klass.scope(:by_company, lambda { |company|
          if inst.respond_to? :company_id then
            return {:conditions => ["`#{inst.class.table_name}`.`company_id` = ?", company.id]}
          end
       })
       # *args is an array where the first argument to the scope should be the company, with an
       # optional second argument, the current user.
       klass.scope(:scopied, lambda { |*args|
          if args.first and args[1] then
            klass.send(:existing).by_company(args.first).by_user(args[1])
          elsif args.first and not args[1]
            klass.send(:existing).by_company(args.first)
          elsif args[1] and not args.first then
            klass.send(:existing).by_user(args[1])
          else
            klass.send(:existing)
          end
       } )
    rescue
      # we don't really consider errors relevant here. We just do this so it doesn't crash
      # during rake tasks.
    end # end begin rescue block
  end
end
