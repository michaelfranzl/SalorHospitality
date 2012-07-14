# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tax_item do
    tax_id 1
    item_id 1
    booking_item_id 1
    order_id 1
    booking_id 1
    settlement_id 1
    gro 1.5
    net 1.5
    tax 1.5
    company_id 1
    vendor_id 1
  end
end
