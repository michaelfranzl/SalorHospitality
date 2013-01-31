class Email < ActiveRecord::Base
  include Scope
  attr_accessible :body, :company_id, :order_id, :receiptient, :sender, :settlement_id, :subject, :technician, :user_id, :vendor_id
  
  belongs_to :company
  belongs_to :vendor
end
