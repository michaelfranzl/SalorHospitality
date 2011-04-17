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

ActiveRecord::Schema.define(:version => 20110417061423) do

  create_table "articles", :force => true do |t|
    t.string   "name"
    t.string   "format_name"
    t.string   "format_division"
    t.string   "description"
    t.text     "recipe"
    t.integer  "category_id"
    t.float    "price"
    t.boolean  "menucard",        :default => true
    t.boolean  "blackboard"
    t.boolean  "waiterpad"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",          :default => false
    t.integer  "sort"
    t.string   "usage"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "tax_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
    t.string   "icon"
    t.string   "color"
    t.integer  "usage"
  end

  create_table "cost_centers", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ingredients", :force => true do |t|
    t.float    "amount"
    t.integer  "article_id"
    t.integer  "stock_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "count"
    t.integer  "article_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "partial_order"
    t.integer  "sort"
    t.integer  "quantity_id"
    t.integer  "storno_status",  :default => 0
    t.string   "comment"
    t.float    "price"
    t.integer  "printed_count",  :default => 0
    t.integer  "item_id"
    t.integer  "storno_item_id"
    t.integer  "tax_id"
  end

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
  end

  create_table "options", :force => true do |t|
    t.integer  "category_id"
    t.integer  "option_id"
    t.string   "name"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.boolean  "finished",        :default => false
    t.integer  "table_id"
    t.integer  "user_id"
    t.integer  "settlement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "sum",             :default => 0.0
    t.integer  "parent_order_id"
    t.integer  "order_id"
    t.integer  "cost_center_id"
    t.string   "printed_from"
    t.integer  "nr"
    t.integer  "credit",          :default => 0
    t.integer  "tax_id"
  end

  create_table "quantities", :force => true do |t|
    t.string   "prefix"
    t.float    "price"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => true
    t.boolean  "hidden",     :default => false
    t.string   "postfix"
    t.integer  "sort"
    t.string   "usage"
  end

  create_table "settlements", :force => true do |t|
    t.float    "revenue"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stocks", :force => true do |t|
    t.float    "balance"
    t.string   "unit"
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tables", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "left"
    t.integer  "top"
    t.integer  "width",        :default => 70
    t.integer  "height",       :default => 45
    t.integer  "left_ipod"
    t.integer  "top_ipod"
    t.integer  "width_ipod",   :default => 100
    t.integer  "height_ipod",  :default => 60
    t.string   "abbreviation"
    t.integer  "user_id"
  end

  create_table "taxes", :force => true do |t|
    t.integer  "percent"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "letter"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role"
    t.string   "color"
    t.string   "language"
  end

end
