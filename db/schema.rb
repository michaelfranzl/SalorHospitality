# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111212152437) do

  create_table "articles", :force => true do |t|
    t.string   "name"
    t.string   "format_name"
    t.string   "format_division"
    t.string   "description"
    t.text     "recipe"
    t.integer  "category_id"
    t.float    "price"
    t.boolean  "menucard",                     :default => true
    t.boolean  "blackboard"
    t.boolean  "waiterpad"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",                       :default => false
    t.integer  "sort"
    t.integer  "usage",           :limit => 1, :default => 0
    t.integer  "position"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "articles", ["category_id"], :name => "index_articles_on_category_id"
  add_index "articles", ["company_id"], :name => "index_articles_company_id"
  add_index "articles", ["name", "description", "price"], :name => "index_articles_on_name_and_description_and_price"
  add_index "articles", ["position"], :name => "index_articles_on_position"

  create_table "cash_drawers", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
    t.integer "vendor_id"
    t.integer "company_id"
  end

  create_table "cash_registers", :force => true do |t|
    t.string  "name"
    t.integer "vendor_id"
    t.integer "company_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "tax_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon"
    t.string   "color"
    t.integer  "vendor_printer_id",   :default => 0
    t.integer  "position"
    t.boolean  "hidden",              :default => false
    t.integer  "preparation_user_id"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "categories", ["company_id"], :name => "index_categories_company_id"
  add_index "categories", ["name"], :name => "index_categories_on_name"
  add_index "categories", ["position"], :name => "index_categories_on_position"
  add_index "categories", ["tax_id"], :name => "index_categories_on_tax_id"
  add_index "categories", ["vendor_printer_id"], :name => "index_categories_on_vendor_printer_id"

  create_table "categories_options", :id => false, :force => true do |t|
    t.integer  "category_id"
    t.integer  "option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string "name"
  end

  create_table "cost_centers", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "hidden"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "cost_centers", ["company_id"], :name => "index_cost_centers_company_id"

  create_table "coupons", :force => true do |t|
    t.string   "name"
    t.float    "amount",              :default => 0.0
    t.integer  "ctype"
    t.string   "sku"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "more_than_1_allowed", :default => true
    t.integer  "article_id"
    t.boolean  "time_based",          :default => false
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vendor_id"
  end

  add_index "coupons", ["company_id"], :name => "coupons_company_id_index"

  create_table "coupons_orders", :id => false, :force => true do |t|
    t.integer "coupon_id"
    t.integer "order_id"
  end

  add_index "coupons_orders", ["coupon_id"], :name => "coupons_orders_coupon_id_index"
  add_index "coupons_orders", ["order_id"], :name => "coupons_orders_order_id_index"

  create_table "customers", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
    t.text     "address"
    t.string   "city"
    t.string   "state"
    t.string   "postalcode"
    t.string   "m_number"
    t.string   "m_points"
    t.string   "email"
    t.string   "telephone"
    t.string   "cellphone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  create_table "customers_items", :id => false, :force => true do |t|
    t.integer "customer_id"
    t.integer "item_id"
  end

  create_table "customers_orders", :id => false, :force => true do |t|
    t.integer "customer_id"
    t.integer "order_id"
  end

  create_table "discounts", :force => true do |t|
    t.string   "name"
    t.float    "amount"
    t.integer  "dtype"
    t.integer  "category_id"
    t.integer  "company_id"
    t.integer  "article_id"
    t.boolean  "time_based"
    t.integer  "start_time"
    t.integer  "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vendor_id"
  end

  add_index "discounts", ["article_id"], :name => "index_discounts_article_id"
  add_index "discounts", ["category_id"], :name => "index_discounts_category_id"
  add_index "discounts", ["company_id"], :name => "index_discounts_company_id"

  create_table "discounts_orders", :id => false, :force => true do |t|
    t.integer "order_id"
    t.integer "discount_id"
  end

  add_index "discounts_orders", ["order_id"], :name => "index_discounts_orders_order_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "groups", ["company_id"], :name => "index_groups_company_id"
  add_index "groups", ["name"], :name => "index_groups_on_name"

  create_table "images", :force => true do |t|
    t.string   "name"
    t.string   "imageable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "imageable_id"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "images", ["imageable_id", "imageable_type"], :name => "index_images_on_imageable_id_and_imageable_type"

  create_table "ingredients", :force => true do |t|
    t.float    "amount"
    t.integer  "article_id"
    t.integer  "stock_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "ingredients", ["article_id"], :name => "index_ingredients_on_article_id"
  add_index "ingredients", ["stock_id"], :name => "index_ingredients_on_stock_id"

  create_table "items", :force => true do |t|
    t.integer  "count",               :limit => 1
    t.integer  "article_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "partial_order"
    t.integer  "sort"
    t.integer  "quantity_id"
    t.integer  "storno_status",       :limit => 1, :default => 0
    t.string   "comment"
    t.float    "price"
    t.integer  "printed_count",       :limit => 1, :default => 0
    t.integer  "item_id"
    t.integer  "storno_item_id"
    t.integer  "tax_id"
    t.integer  "max_count",                        :default => 0
    t.integer  "usage"
    t.integer  "priority"
    t.integer  "preparation_count"
    t.integer  "delivery_count"
    t.string   "preparation_comment"
    t.integer  "user_id"
    t.integer  "preparation_user_id"
    t.integer  "delivery_user_id"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "items", ["article_id"], :name => "index_items_on_article_id"
  add_index "items", ["company_id"], :name => "index_items_company_id"
  add_index "items", ["item_id"], :name => "index_items_on_item_id"
  add_index "items", ["order_id"], :name => "index_items_on_order_id"
  add_index "items", ["priority"], :name => "index_items_on_priority"
  add_index "items", ["quantity_id"], :name => "index_items_on_quantity_id"
  add_index "items", ["sort"], :name => "index_items_on_sort"
  add_index "items", ["storno_item_id"], :name => "index_items_on_storno_item_id"
  add_index "items", ["tax_id"], :name => "index_items_on_tax_id"

  create_table "items_options", :id => false, :force => true do |t|
    t.integer  "item_id"
    t.integer  "option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items_printoptions", :id => false, :force => true do |t|
    t.integer  "item_id"
    t.integer  "option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logins", :force => true do |t|
    t.string   "ip"
    t.string   "email"
    t.string   "reverselookup"
    t.string   "loginname"
    t.string   "realname"
    t.string   "referer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  create_table "options", :force => true do |t|
    t.integer  "option_id"
    t.string   "name"
    t.float    "price",      :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     :default => false
    t.integer  "position"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "options", ["company_id"], :name => "index_options_company_id"
  add_index "options", ["name"], :name => "index_options_on_name"
  add_index "options", ["option_id"], :name => "index_options_on_option_id"

  create_table "orders", :force => true do |t|
    t.boolean  "finished",       :default => false
    t.integer  "table_id"
    t.integer  "user_id"
    t.integer  "settlement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "sum",            :default => 0.0
    t.integer  "order_id"
    t.integer  "cost_center_id"
    t.string   "printed_from"
    t.integer  "nr"
    t.integer  "tax_id"
    t.boolean  "print_pending"
    t.float    "storno_sum",     :default => 0.0
    t.string   "note"
    t.integer  "customer_id"
    t.integer  "m_points"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "orders", ["company_id"], :name => "index_orders_company_id"
  add_index "orders", ["cost_center_id"], :name => "index_orders_on_cost_center_id"
  add_index "orders", ["customer_id"], :name => "index_orders_on_customer_id"
  add_index "orders", ["nr"], :name => "index_orders_on_nr"
  add_index "orders", ["order_id"], :name => "index_orders_on_order_id"
  add_index "orders", ["settlement_id"], :name => "index_orders_on_settlement_id"
  add_index "orders", ["table_id"], :name => "index_orders_on_table_id"
  add_index "orders", ["tax_id"], :name => "index_orders_on_tax_id"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "pages", :force => true do |t|
    t.boolean  "active",     :default => true
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
    t.string   "color"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  create_table "pages_partials", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "partial_id"
  end

  create_table "partials", :force => true do |t|
    t.integer  "left"
    t.integer  "top"
    t.integer  "presentation_id", :default => 1
    t.text     "blurb"
    t.boolean  "active",          :default => true
    t.boolean  "hidden"
    t.integer  "model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "font"
    t.integer  "size"
    t.integer  "image_size"
    t.string   "color"
    t.integer  "width"
    t.string   "align"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "partials", ["model_id"], :name => "index_partials_on_model_id"
  add_index "partials", ["presentation_id"], :name => "index_partials_on_presentation_id"

  create_table "presentations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "markup"
    t.text     "code"
    t.string   "model"
    t.boolean  "active",      :default => true
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "presentations", ["model"], :name => "index_presentations_on_model"
  add_index "presentations", ["name"], :name => "index_presentations_on_name"

  create_table "quantities", :force => true do |t|
    t.string   "prefix"
    t.float    "price"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                  :default => true
    t.boolean  "hidden",                  :default => false
    t.string   "postfix"
    t.integer  "sort"
    t.integer  "usage",      :limit => 1, :default => 0
    t.integer  "position"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "quantities", ["article_id"], :name => "index_quantities_on_article_id"
  add_index "quantities", ["company_id"], :name => "index_quantities_company_id"
  add_index "quantities", ["position"], :name => "index_quantities_on_position"

  create_table "reservations", :force => true do |t|
    t.datetime "res_datetime"
    t.integer  "party_size"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "table_id"
    t.integer  "company_id"
    t.text     "diet_restrictions"
    t.string   "occasion"
    t.string   "honor"
    t.text     "allergies"
    t.text     "other"
    t.text     "menu_selection"
    t.string   "fb_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fb_res_id"
    t.integer  "vendor_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "permissions", :limit => 1000, :default => "--- []\n\n"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "roles", ["company_id"], :name => "index_roles_company_id"

  create_table "settlements", :force => true do |t|
    t.float    "revenue"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finished"
    t.float    "initial_cash"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "settlements", ["company_id"], :name => "index_settlements_company_id"
  add_index "settlements", ["user_id"], :name => "index_settlements_on_user_id"

  create_table "stocks", :force => true do |t|
    t.float    "balance"
    t.string   "unit"
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "stocks", ["company_id"], :name => "index_stocks_company_id"
  add_index "stocks", ["group_id"], :name => "index_stocks_on_group_id"

  create_table "tables", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "left"
    t.integer  "top"
    t.integer  "width",          :default => 70
    t.integer  "height",         :default => 45
    t.integer  "left_mobile"
    t.integer  "top_mobile"
    t.integer  "width_mobile",   :default => 70
    t.integer  "height_mobile",  :default => 45
    t.string   "abbreviation"
    t.integer  "user_id"
    t.boolean  "enabled",        :default => true
    t.boolean  "hidden",         :default => false
    t.boolean  "rotate"
    t.integer  "active_user_id"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "tables", ["active_user_id"], :name => "index_tables_on_active_user_id"
  add_index "tables", ["company_id"], :name => "index_tables_company_id"
  add_index "tables", ["user_id"], :name => "index_tables_on_user_id"

  create_table "tables_users", :id => false, :force => true do |t|
    t.integer  "table_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taxes", :force => true do |t|
    t.integer  "percent"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "letter"
    t.string   "color"
    t.boolean  "hidden"
    t.integer  "company_id"
    t.integer  "vendor_id"
  end

  add_index "taxes", ["company_id"], :name => "index_taxes_company_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
    t.string   "color"
    t.string   "language"
    t.boolean  "active",             :default => true
    t.boolean  "hidden",             :default => false
    t.integer  "company_id"
    t.boolean  "is_owner",           :default => false
    t.integer  "owner_id"
    t.integer  "vendor_id"
    t.integer  "screenlock_timeout", :default => -1
    t.boolean  "automatic_printing"
  end

  add_index "users", ["role_id"], :name => "index_users_on_role_id"

  create_table "users_vendors", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "vendor_id"
  end

  create_table "vendor_printers", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.integer  "company_id"
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "copies",     :default => 1
    t.integer  "vendor_id"
  end

  add_index "vendor_printers", ["company_id"], :name => "index_vendor_printers_on_company_id"

  create_table "vendors", :force => true do |t|
    t.string   "name",                                             :default => "Bill Gastro"
    t.string   "subdomain",                                        :default => "demo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invoice_subtitle",                                 :default => ""
    t.string   "address",                                          :default => ""
    t.string   "revenue_service_tax_number",                       :default => ""
    t.string   "invoice_slogan1",                                  :default => ""
    t.string   "invoice_slogan2",                                  :default => ""
    t.string   "internet_address",                                 :default => "www.billgastro.com"
    t.string   "email",                                            :default => "office@billgastro.com"
    t.integer  "largest_order_number",                             :default => 0
    t.string   "unused_order_numbers",                             :default => "--- []\n\n"
    t.string   "country"
    t.string   "bank_account1"
    t.string   "bank_account2"
    t.integer  "time_offset",                                      :default => 0
    t.string   "mode"
    t.text     "cache",                      :limit => 2147483647
    t.boolean  "use_order_numbers",                                :default => true
    t.integer  "user_id"
    t.string   "res_fetch_url"
    t.string   "res_confirm_url"
    t.integer  "company_id"
  end

  add_index "vendors", ["user_id"], :name => "index_company_user_id"

end
