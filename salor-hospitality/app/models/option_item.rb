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
    @found = nil
    @tests = {
      self.id => {
                       :tests => [],
                       }
    }
    
    if self.item.refunded == true
      perform_test({
                    :should => 0,
                    :actual => self.sum,
                    :msg => "A refunded OptionItem should have the price of zero",
                    :type => :optionItemRefundZero,
                    })
    else
      perform_test({
                    :should => self.sum.round(2),
                    :actual => (self.price * self.count).round(2),
                    :msg => "The sum attribute of an OptionItem should be price times count",
                    :type => :optionItemSumCorrect,
                    })
    end
    
    perform_test({
                  :should => self.count,
                  :actual => self.item.count,
                  :msg => "An OptionItem should have the same count as the Item",
                  :type => :optionItemSameCountAsItem,
                  })
    
    perform_test({
                  :should => [self.hidden, self.hidden_by, self.hidden_at],
                  :actual => [self.item.hidden, self.item.hidden_by, self.item.hidden_at],
                  :msg => "An OptionItem should have the same hidden attributes as the Item",
                  :type => :optionItemSameHiddenAttributes,
                  })

    perform_test({
                  :should => [self.vendor_id, self.company_id, self.order_id],
                  :actual => [self.item.vendor_id, self.item.company_id, self.item.order_id],
                  :msg => "An OptionItem should have the same belongs_to attributes as the Item",
                  :type => :optionItemSameBelongsToAttributes,
                  })

    puts "\n *** WARNING: OptionItem is deleted, tests are irrelevant! *** \n" if self.hidden
    return @tests, @found
  end
  
  def hide(by_user)
    self.hidden = true
    self.hidden_by = by_user
    self.hidden_at = Time.now
    self.save
  end
  
  private
  
  def perform_test(options)
    should = options[:should]
    actual = options[:actual]
    pass = should == actual
    type = options[:type]
    msg = options[:msg]
    @tests[self.id][:tests] << {
      :type => type,
      :msg => msg,
      :should => should,
      :actual => actual
    } if pass == false
    @found = true if pass == false
  end
  
  
end
