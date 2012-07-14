class TaxItem < ActiveRecord::Base
  attr_accessible :booking_id, :booking_item_id, :company_id, :gro, :item_id, :net, :order_id, :settlement_id, :tax, :tax_id, :vendor_id
  
  belongs_to :vendor
  belongs_to :company
  belongs_to :item
  belongs_to :booking_item
  belongs_to :order
  belongs_to :booking
  belongs_to :settlement
end
