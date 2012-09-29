class OptionItem < ActiveRecord::Base
  include Scope
  belongs_to :company
  belongs_to :vendor
  belongs_to :order
  belongs_to :item
  belongs_to :option
  
  def calculate_totals
    self.count = self.item.count
    if self.hidden
      self.sum = 0
    else
      self.sum = self.price * self.count
    end
    self.save
  end
  
  def check
    if self.item.refunded
      test1 = self.sum.round(2) == 0
      raise "OptionItem test1 failed for id #{ self.id }" unless test1
    end
    test2 = self.sum.round(2) == (self.price * self.count).round(2)
    raise "OptionItem test2 failed for id #{ self.id }" unless test2
    test3 = self.count == self.item.count
    raise "OptionItem test3 failed for id #{ self.id }" unless test3
  end
  
  def hide(by_user)
    self.hidden = true
    self.hidden_by = by_user
    self.save
  end
  
end
