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
    puts "============================================"
    puts "Checking internal consistency of option #{ self.id}"
    
    option_equality = (self.sum == self.price * self.count)
    
    if option_equality
      puts "PASSED"
    else
      puts "FAIL"
      return false
    end
    return true
  end
  
end
