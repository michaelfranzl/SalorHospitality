# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_method_item, :class => 'PaymentMethodItems' do
    payment_method_id 1
    amount 1.5
    company_id 1
    vendor_id 1
  end
end
