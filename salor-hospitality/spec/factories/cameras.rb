# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :camera do
    name "MyString"
    url "MyString"
    enabled false
    vendor_id 1
    company_id 1
    hidden false
    hidden_by 1
    hidden_at "2012-12-10 12:29:39"
  end
end
