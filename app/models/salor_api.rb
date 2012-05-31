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
