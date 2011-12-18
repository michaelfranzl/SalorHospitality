FactoryGirl.define do
  factory :user do
    #sequence(:login) { |n| "user#{n}" }
    login "user"
    password "secret"
    title "Mr. User" 
    company
    role 
  end

  factory :invalid_user, :class => User do
    login "user"
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

  factory :category do
    name "Category"
    company
    vendor
    tax
  end

  factory :article do
    name "Article"
    price 10
    company
    vendor
    category
  end

  factory :tax do
    name "10%"
    percent 10
  end

  factory :quantity do
    prefix "Prefix"
    postfix "Postfix"
    price 11
    company
    vendor
    article
  end

  factory :item_from_article, :class => Item do
    count 1
    article
    company
    vendor
  end

  factory :item_from_quantity, :class => Item do
    count 1
    article
    quantity
    company
    vendor
  end
end
