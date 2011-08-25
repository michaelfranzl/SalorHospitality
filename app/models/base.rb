module Base
  def set_model_owner(u=nil,c=nil)
    if u.nil? then
      u = $USER
    end
    if c.nil? then
      c = $COMPANY
    end
    if self.respond_to? :user_id then
      self.user_id = u.id
    end
    if self.respond_to? :owner_id then
      self.owner_id = u.get_owner.id
    end
    # $COMPANY must be set whenever this is called, which
    # should only be called when creating/saving models
    if self.respond_to? :company_id then
      self.company_id = c.id if c
    end
  end
  def get_owner
    if self.is_owner then
      return self
    else
      return self.owner
    end
  end
end
