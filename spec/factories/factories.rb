# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


FactoryGirl.define do
  factory :company do
    name "Test Company"
  end
  factory :vendor do
    name "Test Vendor 0 0"
    association :company
  end
  factory :role, :aliases => [:role_superuser] do  
    name "Role Superuser"
    permissions ["take_orders", "decrement_items", "finish_orders", "split_items", "move_tables", "make_storno", "assign_cost_center", "move_order", "change_waiter", "manage_articles_categories_options", "finish_all_settlements", "finish_own_settlement", "view_all_settlements", "manage_business_invoice", "view_statistics", "manage_users", "manage_settings"]
  end
  factory :user, :aliases => [:user_superuser] do
    login "user"
    password "xxx"
    title "Mr. Superuser"
    onscreen_keyboard_enabled false
    role
    association :company
    vendors { |v| [v.association(:vendor)] }
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
    position 0
  end
  factory :article do
    name "Article"
    price 10
    association :company
    association :vendor
    category
  end
  factory :tax do
    name "10%"
    percent 10
    association :company
    association :vendor
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
