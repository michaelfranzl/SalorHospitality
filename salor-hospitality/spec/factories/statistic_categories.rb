# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :statistic_category do
    name "MyString"
    hidden false
    company_id 1
    vendor_id 1
    active false
  end
end
