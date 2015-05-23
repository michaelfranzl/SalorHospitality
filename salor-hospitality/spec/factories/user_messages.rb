# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_message, :class => 'UserMessages' do
    sender_id 1
    receipient_id 1
    reply_id 1
    displayed false
    subject "MyString"
    body "MyText"
    type ""
    vendor_id 1
    company_id 1
    hidden false
    hidden_by 1
    hidden_at "2013-08-31 09:34:17"
  end
end
