class Email < ActiveRecord::Base
  attr_accessible :body, :company_id, :order_id, :receiptient, :sender, :settlement_id, :subject, :technician, :user_id, :vendor_id
end
