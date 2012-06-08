class PaymentMethodItem < ActiveRecord::Base
  attr_accessible :amount, :company_id, :payment_method_id, :vendor_id, :order_id, :booking_id
  include Scope
  belongs_to :payment_method_item
  belongs_to :order
  belongs_to :vendor
  belongs_to :company
end
