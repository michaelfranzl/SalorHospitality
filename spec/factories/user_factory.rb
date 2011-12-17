FactoryGirl.define do
  factory :user do
    #sequence(:login) { |n| "user#{n}" }
    login "user"
    password "secret"
    title "Mr. User" 
    company
    role 
  end

  factory :role do
    name "Admin"
    permissions ["take_orders", "decrement_items", "finish_orders", "split_items", "move_tables", "make_storno", "assign_cost_center", "move_order", "change_waiter", "manage_articles_categories_options", "finish_all_settlements", "finish_own_settlement", "view_all_settlements", "manage_business_invoice", "view_statistics", "manage_users", "manage_settings"]
  end

  factory :company do
    name "Test Company"
  end

  factory :vendor do
    name "Test Vendor"
  end

  factory :user_with_vendor, :parent => :user do |user|
    user.after_create { |u| Factory(:vendor, :users => [u]) }
  end
end
