# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :booking do
    from "2012-06-05 15:31:50"
    to "2012-06-05 15:31:50"
    customer_id 1
    sum 1.5
    hidden false
    paid false
    note "MyText"
    vendor_id 1
    company_id 1
  end
end
