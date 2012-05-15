class PaymentMethod < ActiveRecord::Base
  attr_accessible :amount, :name, :order_id
  belongs_to :order
  def amount=(amnt)
    write_attribute :amount,amnt.to_s.gsub(',','.')
  end
end
