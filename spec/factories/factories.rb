FactoryGirl.define do
  factory :company0, :class => Company, :aliases => [:company] do
    name "Test Company 0"
  end

  factory :company1, :class => Company do
    name "Test Company 1"
  end

  factory :vendor00, :class => Vendor, :aliases => [:vendor] do
    name "Test Vendor 0 0"
    association :company, :factory => :company0
  end

  factory :vendor01, :class => Vendor do
    name "Test Vendor 0 1"
    association :company, :factory => :company0
  end

  factory :vendor10, :class => Vendor do
    name "Test Vendor 1 0"
    association :company, :factory => :company1
  end

  factory :vendor11, :class => Vendor do
    name "Test Vendor 1 1"
    association :company, :factory => :company1
  end

  factory :role, :class => Role, :aliases => [:role_superuser] do  
    name "Role Superuser"
    permissions ["take_orders", "decrement_items", "finish_orders", "split_items", "move_tables", "make_storno", "assign_cost_center", "move_order", "change_waiter", "manage_articles_categories_options", "finish_all_settlements", "finish_own_settlement", "view_all_settlements", "manage_business_invoice", "view_statistics", "manage_users", "manage_settings"]
  end

  factory :user000, :class => User, :aliases => [:user, :user_superuser] do |user|
    login "user000"
    password "000"
    title "Mr. Superuser 0 0 0" 
    role
    association :company, :factory => :company0
    user.after_create { |u| Factory(:vendor00, :users => [u]) }
  end

  factory :user010, :class => User do |user|
    login "user010"
    password "010"
    title "Mr. Superuser 0 1 0" 
    role
    association :company, :factory => :company0
    user.after_create { |u| Factory(:vendor01, :users => [u]) }
  end

  factory :user100, :class => User do |user|
    login "user100"
    password "100"
    title "Mr. Superuser 1 0 0" 
    role
    association :company, :factory => :company1
    user.after_create { |u| Factory(:vendor10, :users => [u]) }
  end

  factory :user110, :class => User do |user|
    login "user110"
    password "110"
    title "Mr. Superuser 1 1 0" 
    role
    association :company, :factory => :company1
    user.after_create { |u| Factory(:vendor11, :users => [u]) }
  end

  factory :invalid_user, :class => User do
    login "invalid user"
    title "Mr. Invalid User"
  end

  factory :category do
    name "Category"
    company
    vendor
    tax
  end

  factory :article000, :class => Article, :aliases => [:article] do
    name "Article 0 0 0"
    price 10
    association :company, :factory => :company0
    association :vendor, :factory => :vendor00
    category
  end

  factory :article010, :class => Article do
    name "Article 0 1 0"
    price 10
    association :company, :factory => :company0
    association :vendor, :factory => :vendor01
    category
  end

  factory :article100, :class => Article do
    name "Article 1 0 0"
    price 10
    association :company, :factory => :company1
    association :vendor, :factory => :vendor00
    category
  end

  factory :article110, :class => Article do
    name "Article 1 1 0"
    price 10
    association :company, :factory => :company1
    association :vendor, :factory => :vendor11
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
