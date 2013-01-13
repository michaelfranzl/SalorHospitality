# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    sender "MyString"
    receiptient "MyString"
    subject "MyString"
    body "MyText"
    technician false
    vendor_id 1
    company_id 1
    user_id 1
    order_id 1
    settlement_id 1
  end
end
