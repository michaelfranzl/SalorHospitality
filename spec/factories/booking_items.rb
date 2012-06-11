# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :booking_item do
    booking_id 1
    hidden false
    vendor_id 1
    company_id 1
    guest_type_id 1
    sum 1.5
  end
end
