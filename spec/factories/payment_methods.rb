# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_method do
    name "MyString"
    amount 1.5
    order_id 1
  end
end
