# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_login do
    company_id 1
    vendor_id 1
    user_id 1
    login "2013-07-24 10:28:17"
    logout "2013-07-24 10:28:17"
    duration 1
    hourly_rate 1.5
    hidden false
    hidden_by 1
    hidden_at "2013-07-24 10:28:17"
    ip "MyString"
    auto_logout false
  end
end
