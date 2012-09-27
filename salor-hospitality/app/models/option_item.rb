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
    test1 = self.item.refunded.nil? ? (self.sum == self.price * self.count) : (self.sum == 0)
    raise "OptionItem test1 failed" unless test1
    test2 = self.count == self.item.count
    raise "OptionItem test2 failed" unless test2
  end
  
end
