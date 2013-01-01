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
    tests = []
    
    if self.item.refunded
      tests[1] = self.sum.round(2) == 0
    else
      tests[2] = self.sum.round(2) == (self.price * self.count).round(2)
    end
    
    tests[3] = self.count == self.item.count
    
    messages = []
    0.upto(tests.size-1).each do |i|
      messages << "OptionItem #{ self.id }: test #{i} failed." if tests[i] == false
    end
    return messages
  end
  
  def hide(by_user)
    self.hidden = true
    self.hidden_by = by_user
    self.save
  end
  
end
