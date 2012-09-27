class OptionItem < ActiveRecord::Base
  include Scope
  belongs_to :company
  belongs_to :vendor
  belongs_to :order
  belongs_to :item
  belongs_to :option
  
  def calculate_totals
    puts "======================"
    puts "OPTIONITEM CALC TOTALS"
    puts self.item.inspect
        puts "======================"
    puts "OPTIONITEM CALC TOTALS"
    puts self.inspect
    self.count = self.item.count
    if self.hidden
      self.sum = 0
    else
      self.sum = self.price * self.count
    end
    self.save
  end
  
end
