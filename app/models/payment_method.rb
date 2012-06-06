class PaymentMethod < ActiveRecord::Base
  attr_accessible :amount, :name, :order_id
  include Scope
  belongs_to :order
  belongs_to :vendor
  belongs_to :company

  def amount=(amnt)
    write_attribute :amount,amnt.to_s.gsub(',','.')
  end
end
