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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150612074929) do

  create_table "articles", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "recipe"
    t.integer  "category_id"
    t.float    "price",                 limit: 24
    t.boolean  "active",                           default: true
    t.boolean  "waiterpad"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "hidden",                           default: false
    t.integer  "sort"
    t.integer  "position"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.integer  "tax_id"
    t.integer  "statistic_category_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.string   "sku"
  end

  add_index "articles", ["category_id"], name: "index_articles_on_category_id", using: :btree
  add_index "articles", ["company_id"], name: "index_articles_company_id", using: :btree
  add_index "articles", ["company_id"], name: "index_articles_on_company_id", using: :btree
  add_index "articles", ["hidden"], name: "index_articles_on_hidden", using: :btree
  add_index "articles", ["name", "description", "price"], name: "index_articles_on_name_and_description_and_price", using: :btree
  add_index "articles", ["position"], name: "index_articles_on_position", using: :btree
  add_index "articles", ["vendor_id"], name: "index_articles_on_vendor_id", using: :btree

  create_table "articles_taxes", id: false, force: true do |t|
    t.integer "tax_id"
    t.integer "article_id"
  end

  create_table "booking_items", force: true do |t|
    t.integer  "booking_id"
    t.boolean  "hidden"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.integer  "guest_type_id"
    t.float    "sum",             limit: 24,    default: 0.0
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "count",                         default: 1
    t.integer  "hidden_by"
    t.float    "base_price",      limit: 24
    t.float    "refund_sum",      limit: 24,    default: 0.0
    t.string   "taxes",           limit: 10000, default: "--- {}\n"
    t.datetime "from_date"
    t.datetime "to_date"
    t.integer  "season_id"
    t.integer  "duration"
    t.integer  "booking_item_id"
    t.string   "ui_parent_id"
    t.string   "ui_id"
    t.float    "unit_sum",        limit: 24
    t.integer  "room_id"
    t.boolean  "date_locked",                   default: false
    t.float    "tax_sum",         limit: 24
    t.datetime "hidden_at"
  end

  add_index "booking_items", ["booking_id"], name: "index_booking_items_on_booking_id", using: :btree
  add_index "booking_items", ["booking_item_id"], name: "index_booking_items_on_booking_item_id", using: :btree
  add_index "booking_items", ["company_id"], name: "index_booking_items_on_company_id", using: :btree
  add_index "booking_items", ["guest_type_id"], name: "index_booking_items_on_guest_type_id", using: :btree
  add_index "booking_items", ["hidden"], name: "index_booking_items_on_hidden", using: :btree
  add_index "booking_items", ["room_id"], name: "index_booking_items_on_room_id", using: :btree
  add_index "booking_items", ["season_id"], name: "index_booking_items_on_season_id", using: :btree
  add_index "booking_items", ["ui_id"], name: "index_booking_items_on_ui_id", using: :btree
  add_index "booking_items", ["ui_parent_id"], name: "index_booking_items_on_ui_parent_id", using: :btree
  add_index "booking_items", ["vendor_id"], name: "index_booking_items_on_vendor_id", using: :btree

  create_table "bookings", force: true do |t|
    t.datetime "from_date"
    t.datetime "to_date"
    t.integer  "customer_id"
    t.float    "sum",              limit: 24,    default: 0.0
    t.boolean  "hidden"
    t.boolean  "paid",                           default: false
    t.text     "note"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "room_id"
    t.boolean  "finished",                       default: false
    t.integer  "user_id"
    t.integer  "hidden_by"
    t.float    "refund_sum",       limit: 24,    default: 0.0
    t.integer  "nr"
    t.float    "change_given",     limit: 24
    t.float    "duration",         limit: 24
    t.string   "taxes",            limit: 10000, default: "--- {}\n"
    t.float    "booking_item_sum", limit: 24
    t.datetime "finished_at"
    t.datetime "paid_at"
    t.float    "tax_sum",          limit: 24
    t.datetime "hidden_at"
  end

  add_index "bookings", ["company_id"], name: "index_bookings_on_company_id", using: :btree
  add_index "bookings", ["hidden"], name: "index_bookings_on_hidden", using: :btree
  add_index "bookings", ["vendor_id"], name: "index_bookings_on_vendor_id", using: :btree

  create_table "cameras", force: true do |t|
    t.string   "name"
    t.string   "host_internal"
    t.string   "host_external"
    t.string   "port"
    t.string   "url_stream"
    t.string   "description"
    t.boolean  "active",        default: true
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "url_snapshot"
  end

  create_table "cash_drawers", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "cash_registers", force: true do |t|
    t.string   "name"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "icon"
    t.string   "color"
    t.integer  "vendor_printer_id",   default: 0
    t.integer  "position"
    t.integer  "company_id"
    t.boolean  "hidden",              default: false
    t.integer  "preparation_user_id"
    t.integer  "vendor_id"
    t.boolean  "active",              default: true
    t.boolean  "separate_print"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "categories", ["company_id"], name: "index_categories_company_id", using: :btree
  add_index "categories", ["company_id"], name: "index_categories_on_company_id", using: :btree
  add_index "categories", ["hidden"], name: "index_categories_on_hidden", using: :btree
  add_index "categories", ["name"], name: "index_categories_on_name", using: :btree
  add_index "categories", ["position"], name: "index_categories_on_position", using: :btree
  add_index "categories", ["vendor_id"], name: "index_categories_on_vendor_id", using: :btree
  add_index "categories", ["vendor_printer_id"], name: "index_categories_on_vendor_printer_id", using: :btree

  create_table "categories_options", id: false, force: true do |t|
    t.integer  "category_id"
    t.integer  "option_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "mode",       default: "local"
    t.string   "subdomain"
    t.boolean  "hidden",     default: false
    t.boolean  "active",     default: true
    t.string   "email"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.string   "identifier"
  end

  create_table "cost_centers", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "company_id"
    t.boolean  "hidden"
    t.integer  "vendor_id"
    t.boolean  "no_payment_methods", default: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "cost_centers", ["company_id"], name: "index_cost_centers_company_id", using: :btree

  create_table "coupons", force: true do |t|
    t.string   "name"
    t.float    "amount",              limit: 24, default: 0.0
    t.integer  "ctype"
    t.string   "sku"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "more_than_1_allowed",            default: true
    t.integer  "article_id"
    t.boolean  "time_based",                     default: false
    t.integer  "company_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "coupons", ["company_id"], name: "coupons_company_id_index", using: :btree

  create_table "coupons_orders", id: false, force: true do |t|
    t.integer "coupon_id"
    t.integer "order_id"
  end

  add_index "coupons_orders", ["coupon_id"], name: "coupons_orders_coupon_id_index", using: :btree
  add_index "coupons_orders", ["order_id"], name: "coupons_orders_order_id_index", using: :btree

  create_table "customers", force: true do |t|
    t.string   "first_name",                default: ""
    t.string   "last_name",                 default: ""
    t.string   "company_name",              default: ""
    t.string   "address",                   default: ""
    t.string   "city",                      default: ""
    t.string   "state",                     default: ""
    t.string   "postalcode",                default: ""
    t.string   "m_number"
    t.string   "m_points"
    t.string   "email",                     default: ""
    t.string   "telephone",                 default: ""
    t.string   "cellphone",                 default: ""
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.string   "country",                   default: ""
    t.string   "password"
    t.string   "login"
    t.integer  "role_id"
    t.string   "language"
    t.boolean  "active",                    default: true
    t.boolean  "onscreen_keyboard_enabled", default: false
    t.string   "current_ip"
    t.datetime "last_active_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.integer  "default_table_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.boolean  "logged_in"
    t.string   "tax_info"
  end

  create_table "discounts", force: true do |t|
    t.string   "name"
    t.float    "amount",      limit: 24
    t.integer  "dtype"
    t.integer  "category_id"
    t.integer  "company_id"
    t.integer  "article_id"
    t.boolean  "time_based"
    t.integer  "start_time"
    t.integer  "end_time"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.boolean  "active",                 default: true
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "discounts", ["article_id"], name: "index_discounts_article_id", using: :btree
  add_index "discounts", ["category_id"], name: "index_discounts_category_id", using: :btree
  add_index "discounts", ["company_id"], name: "index_discounts_company_id", using: :btree

  create_table "discounts_orders", id: false, force: true do |t|
    t.integer "order_id"
    t.integer "discount_id"
  end

  add_index "discounts_orders", ["order_id"], name: "index_discounts_orders_order_id", using: :btree

  create_table "emails", force: true do |t|
    t.string   "sender"
    t.string   "receipient"
    t.string   "subject"
    t.text     "body"
    t.boolean  "technician"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "order_id"
    t.integer  "settlement_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "guest_types", force: true do |t|
    t.string   "name"
    t.boolean  "hidden"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "guest_types_taxes", id: false, force: true do |t|
    t.integer "guest_type_id"
    t.integer "tax_id"
  end

  create_table "histories", force: true do |t|
    t.string   "url"
    t.integer  "user_id"
    t.string   "action_taken"
    t.string   "model_type"
    t.integer  "model_id"
    t.string   "ip"
    t.integer  "sensitivity"
    t.text     "changes_made"
    t.text     "params"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.integer  "vendor_id"
    t.integer  "company_id"
  end

  create_table "images", force: true do |t|
    t.string   "name"
    t.string   "imageable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "imageable_id"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.string   "image_type"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "images", ["imageable_id", "imageable_type"], name: "index_images_on_imageable_id_and_imageable_type", using: :btree

  create_table "ingredients", force: true do |t|
    t.float    "amount",     limit: 24
    t.integer  "article_id"
    t.integer  "stock_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "ingredients", ["article_id"], name: "index_ingredients_on_article_id", using: :btree
  add_index "ingredients", ["stock_id"], name: "index_ingredients_on_stock_id", using: :btree

  create_table "items", force: true do |t|
    t.integer  "count",                               default: 1
    t.integer  "article_id"
    t.integer  "order_id"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "position"
    t.integer  "quantity_id"
    t.string   "comment",                             default: ""
    t.float    "price",                 limit: 24
    t.integer  "printed_count",         limit: 1,     default: 0
    t.integer  "item_id"
    t.integer  "max_count",                           default: 0
    t.integer  "company_id"
    t.integer  "preparation_count"
    t.integer  "delivery_count"
    t.string   "preparation_comment",                 default: ""
    t.integer  "user_id"
    t.integer  "preparation_user_id"
    t.integer  "delivery_user_id"
    t.integer  "vendor_id"
    t.string   "delivery_comment",                    default: ""
    t.boolean  "hidden"
    t.integer  "category_id"
    t.float    "tax_percent",           limit: 24
    t.float    "tax_sum",               limit: 24
    t.float    "sum",                   limit: 24
    t.integer  "hidden_by"
    t.boolean  "refunded"
    t.float    "refund_sum",            limit: 24
    t.integer  "refunded_by"
    t.integer  "settlement_id"
    t.integer  "cost_center_id"
    t.text     "scribe"
    t.binary   "scribe_escpos"
    t.string   "taxes",                 limit: 10000, default: "--- {}\n"
    t.integer  "confirmation_count"
    t.integer  "statistic_category_id"
    t.datetime "hidden_at"
    t.integer  "min_count"
    t.boolean  "price_changed"
    t.integer  "price_changed_by"
    t.integer  "position_category"
  end

  add_index "items", ["article_id"], name: "index_items_on_article_id", using: :btree
  add_index "items", ["category_id"], name: "index_items_on_category_id", using: :btree
  add_index "items", ["company_id"], name: "index_items_company_id", using: :btree
  add_index "items", ["company_id"], name: "index_items_on_company_id", using: :btree
  add_index "items", ["cost_center_id"], name: "index_items_on_cost_center_id", using: :btree
  add_index "items", ["count"], name: "index_items_on_count", using: :btree
  add_index "items", ["delivery_count"], name: "index_items_on_delivery_count", using: :btree
  add_index "items", ["delivery_user_id"], name: "index_items_on_delivery_user_id", using: :btree
  add_index "items", ["hidden"], name: "index_items_on_hidden", using: :btree
  add_index "items", ["item_id"], name: "index_items_on_item_id", using: :btree
  add_index "items", ["order_id"], name: "index_items_on_order_id", using: :btree
  add_index "items", ["position"], name: "index_items_on_sort", using: :btree
  add_index "items", ["preparation_count"], name: "index_items_on_preparation_count", using: :btree
  add_index "items", ["preparation_user_id"], name: "index_items_on_preparation_user_id", using: :btree
  add_index "items", ["quantity_id"], name: "index_items_on_quantity_id", using: :btree
  add_index "items", ["refunded"], name: "index_items_on_refunded", using: :btree
  add_index "items", ["settlement_id"], name: "index_items_on_settlement_id", using: :btree
  add_index "items", ["vendor_id"], name: "index_items_on_vendor_id", using: :btree

  create_table "option_items", force: true do |t|
    t.integer  "option_id"
    t.integer  "item_id"
    t.integer  "order_id"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.float    "price",           limit: 24
    t.string   "name"
    t.integer  "count"
    t.float    "sum",             limit: 24
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "no_ticket"
    t.boolean  "separate_ticket"
    t.datetime "hidden_at"
  end

  add_index "option_items", ["company_id"], name: "index_option_items_on_company_id", using: :btree
  add_index "option_items", ["hidden"], name: "index_option_items_on_hidden", using: :btree
  add_index "option_items", ["item_id"], name: "index_option_items_on_item_id", using: :btree
  add_index "option_items", ["option_id"], name: "index_option_items_on_option_id", using: :btree
  add_index "option_items", ["order_id"], name: "index_option_items_on_order_id", using: :btree
  add_index "option_items", ["vendor_id"], name: "index_option_items_on_vendor_id", using: :btree

  create_table "options", force: true do |t|
    t.integer  "option_id"
    t.string   "name"
    t.float    "price",           limit: 24, default: 0.0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "hidden",                     default: false
    t.integer  "position"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.boolean  "active",                     default: true
    t.boolean  "separate_ticket"
    t.boolean  "no_ticket"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "options", ["company_id"], name: "index_options_company_id", using: :btree
  add_index "options", ["company_id"], name: "index_options_on_company_id", using: :btree
  add_index "options", ["hidden"], name: "index_options_on_hidden", using: :btree
  add_index "options", ["name"], name: "index_options_on_name", using: :btree
  add_index "options", ["option_id"], name: "index_options_on_option_id", using: :btree
  add_index "options", ["vendor_id"], name: "index_options_on_vendor_id", using: :btree

  create_table "orders", force: true do |t|
    t.boolean  "finished",                      default: false
    t.integer  "table_id"
    t.integer  "user_id"
    t.integer  "settlement_id"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.float    "sum",             limit: 24,    default: 0.0
    t.integer  "order_id"
    t.integer  "cost_center_id"
    t.string   "printed_from"
    t.integer  "nr"
    t.integer  "tax_id"
    t.float    "refund_sum",      limit: 24,    default: 0.0
    t.integer  "company_id"
    t.string   "note"
    t.integer  "customer_id"
    t.integer  "m_points"
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.float    "tax_sum",         limit: 24
    t.integer  "hidden_by"
    t.boolean  "printed"
    t.boolean  "paid",                          default: false
    t.float    "change_given",    limit: 24
    t.integer  "booking_id"
    t.string   "taxes",           limit: 10000, default: "--- {}\n"
    t.datetime "finished_at"
    t.datetime "paid_at"
    t.boolean  "reactivated"
    t.integer  "reactivated_by"
    t.datetime "reactivated_at"
    t.datetime "hidden_at"
    t.boolean  "printed_interim"
  end

  add_index "orders", ["booking_id"], name: "index_orders_on_booking_id", using: :btree
  add_index "orders", ["company_id"], name: "index_orders_company_id", using: :btree
  add_index "orders", ["company_id"], name: "index_orders_on_company_id", using: :btree
  add_index "orders", ["cost_center_id"], name: "index_orders_on_cost_center_id", using: :btree
  add_index "orders", ["customer_id"], name: "index_orders_on_customer_id", using: :btree
  add_index "orders", ["finished"], name: "index_orders_on_finished", using: :btree
  add_index "orders", ["hidden"], name: "index_orders_on_hidden", using: :btree
  add_index "orders", ["nr"], name: "index_orders_on_nr", using: :btree
  add_index "orders", ["order_id"], name: "index_orders_on_order_id", using: :btree
  add_index "orders", ["paid"], name: "index_orders_on_paid", using: :btree
  add_index "orders", ["settlement_id"], name: "index_orders_on_settlement_id", using: :btree
  add_index "orders", ["table_id"], name: "index_orders_on_table_id", using: :btree
  add_index "orders", ["tax_id"], name: "index_orders_on_tax_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree
  add_index "orders", ["vendor_id"], name: "index_orders_on_vendor_id", using: :btree

  create_table "pages", force: true do |t|
    t.boolean  "active",     default: true
    t.boolean  "hidden"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "width"
    t.integer  "height"
    t.string   "color"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "pages_partials", id: false, force: true do |t|
    t.integer "page_id"
    t.integer "partial_id"
  end

  create_table "partials", force: true do |t|
    t.integer  "left"
    t.integer  "top"
    t.integer  "presentation_id", default: 1
    t.text     "blurb"
    t.boolean  "active",          default: true
    t.boolean  "hidden"
    t.integer  "model_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "font"
    t.integer  "size"
    t.integer  "image_size"
    t.string   "color"
    t.integer  "width"
    t.string   "align"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "partials", ["model_id"], name: "index_partials_on_model_id", using: :btree
  add_index "partials", ["presentation_id"], name: "index_partials_on_presentation_id", using: :btree

  create_table "payment_method_items", force: true do |t|
    t.integer  "payment_method_id"
    t.integer  "order_id"
    t.float    "amount",            limit: 24
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "booking_id"
    t.boolean  "refunded"
    t.boolean  "cash",                         default: false
    t.integer  "refund_item_id"
    t.integer  "settlement_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.integer  "cost_center_id"
    t.boolean  "change",                       default: false
    t.datetime "hidden_at"
    t.integer  "user_id"
  end

  create_table "payment_methods", force: true do |t|
    t.string   "name"
    t.float    "amount",     limit: 24
    t.integer  "order_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "hidden"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.boolean  "cash",                  default: false
    t.boolean  "change",                default: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "presentations", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "markup"
    t.text     "code"
    t.string   "model"
    t.boolean  "active",      default: true
    t.boolean  "hidden"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "presentations", ["model"], name: "index_presentations_on_model", using: :btree
  add_index "presentations", ["name"], name: "index_presentations_on_name", using: :btree

  create_table "quantities", force: true do |t|
    t.string   "prefix",                           default: ""
    t.float    "price",                 limit: 24
    t.integer  "article_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "active",                           default: true
    t.boolean  "hidden",                           default: false
    t.string   "postfix",                          default: ""
    t.integer  "sort"
    t.integer  "position"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.integer  "category_id"
    t.integer  "statistic_category_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.string   "article_name"
    t.string   "sku"
  end

  add_index "quantities", ["article_id"], name: "index_quantities_on_article_id", using: :btree
  add_index "quantities", ["company_id"], name: "index_quantities_company_id", using: :btree
  add_index "quantities", ["company_id"], name: "index_quantities_on_company_id", using: :btree
  add_index "quantities", ["hidden"], name: "index_quantities_on_hidden", using: :btree
  add_index "quantities", ["position"], name: "index_quantities_on_position", using: :btree
  add_index "quantities", ["vendor_id"], name: "index_quantities_on_vendor_id", using: :btree

  create_table "receipts", force: true do |t|
    t.integer  "user_id"
    t.binary   "content"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.integer  "vendor_printer_id"
    t.integer  "bytes_sent"
    t.integer  "bytes_written"
    t.integer  "order_id"
    t.integer  "order_nr"
    t.integer  "settlement_id"
    t.integer  "settlement_nr"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "reservations", force: true do |t|
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
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "fb_res_id"
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "permissions", limit: 10000, default: "--- []\n"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.boolean  "active",                    default: true
    t.boolean  "hidden"
    t.integer  "weight"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "roles", ["company_id"], name: "index_roles_company_id", using: :btree

  create_table "room_prices", force: true do |t|
    t.integer  "room_type_id"
    t.integer  "guest_type_id"
    t.float    "base_price",    limit: 24
    t.boolean  "hidden"
    t.string   "vendor_id"
    t.string   "integer"
    t.integer  "company_id"
    t.boolean  "active",                   default: true
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "season_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "room_prices", ["company_id"], name: "index_room_prices_on_company_id", using: :btree
  add_index "room_prices", ["hidden"], name: "index_room_prices_on_hidden", using: :btree
  add_index "room_prices", ["vendor_id"], name: "index_room_prices_on_vendor_id", using: :btree

  create_table "room_types", force: true do |t|
    t.string   "name"
    t.boolean  "hidden"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "rooms", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "room_type_id"
    t.boolean  "hidden"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "active",       default: true
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "rooms", ["company_id"], name: "index_rooms_on_company_id", using: :btree
  add_index "rooms", ["hidden"], name: "index_rooms_on_hidden", using: :btree
  add_index "rooms", ["vendor_id"], name: "index_rooms_on_vendor_id", using: :btree

  create_table "seasons", force: true do |t|
    t.string   "name"
    t.datetime "from_date"
    t.datetime "to_date"
    t.boolean  "hidden"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "duration"
    t.string   "color"
    t.boolean  "is_master"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "settlements", force: true do |t|
    t.float    "revenue",          limit: 24
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "finished"
    t.float    "initial_cash",     limit: 24
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.float    "sum",              limit: 24
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.integer  "nr"
    t.datetime "hidden_at"
    t.integer  "start_by_user_id"
    t.integer  "stop_by_user_id"
  end

  add_index "settlements", ["company_id"], name: "index_settlements_company_id", using: :btree
  add_index "settlements", ["company_id"], name: "index_settlements_on_company_id", using: :btree
  add_index "settlements", ["user_id"], name: "index_settlements_on_user_id", using: :btree
  add_index "settlements", ["vendor_id"], name: "index_settlements_on_vendor_id", using: :btree

  create_table "statistic_categories", force: true do |t|
    t.string   "name"
    t.boolean  "hidden"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "stocks", force: true do |t|
    t.float    "balance",    limit: 24
    t.string   "unit"
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "stocks", ["company_id"], name: "index_stocks_company_id", using: :btree
  add_index "stocks", ["group_id"], name: "index_stocks_on_group_id", using: :btree

  create_table "surcharge_items", force: true do |t|
    t.integer  "surcharge_id"
    t.integer  "booking_item_id"
    t.float    "amount",          limit: 24
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.integer  "season_id"
    t.integer  "guest_type_id"
    t.boolean  "hidden"
    t.string   "taxes",           limit: 1000, default: "--- {}\n"
    t.float    "sum",             limit: 24
    t.integer  "duration"
    t.integer  "count"
    t.datetime "from_date"
    t.datetime "to_date"
    t.integer  "hidden_by"
    t.float    "tax_sum",         limit: 24
    t.integer  "booking_id"
    t.datetime "hidden_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "surcharge_items", ["booking_id"], name: "index_surcharge_items_on_booking_id", using: :btree
  add_index "surcharge_items", ["booking_item_id"], name: "index_surcharge_items_on_booking_item_id", using: :btree
  add_index "surcharge_items", ["company_id"], name: "index_surcharge_items_on_company_id", using: :btree
  add_index "surcharge_items", ["guest_type_id"], name: "index_surcharge_items_on_guest_type_id", using: :btree
  add_index "surcharge_items", ["hidden"], name: "index_surcharge_items_on_hidden", using: :btree
  add_index "surcharge_items", ["season_id"], name: "index_surcharge_items_on_season_id", using: :btree
  add_index "surcharge_items", ["surcharge_id"], name: "index_surcharge_items_on_surcharge_id", using: :btree
  add_index "surcharge_items", ["vendor_id"], name: "index_surcharge_items_on_vendor_id", using: :btree

  create_table "surcharges", force: true do |t|
    t.string   "name"
    t.integer  "season_id"
    t.integer  "guest_type_id"
    t.float    "amount",        limit: 24, default: 0.0
    t.boolean  "hidden"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "active",                   default: true
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "radio_select"
    t.boolean  "visible",                  default: true
    t.boolean  "selected",                 default: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "surcharges", ["company_id"], name: "index_surcharges_on_company_id", using: :btree
  add_index "surcharges", ["hidden"], name: "index_surcharges_on_hidden", using: :btree
  add_index "surcharges", ["vendor_id"], name: "index_surcharges_on_vendor_id", using: :btree

  create_table "tables", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "left",                  default: 50
    t.integer  "top",                   default: 50
    t.integer  "width",                 default: 70
    t.integer  "height",                default: 45
    t.integer  "left_mobile",           default: 50
    t.integer  "top_mobile",            default: 50
    t.integer  "width_mobile",          default: 70
    t.integer  "height_mobile",         default: 45
    t.boolean  "enabled",               default: true
    t.boolean  "hidden",                default: false
    t.boolean  "rotate"
    t.integer  "company_id"
    t.integer  "active_user_id"
    t.integer  "vendor_id"
    t.boolean  "active",                default: true
    t.integer  "position"
    t.boolean  "booking_table"
    t.boolean  "confirmations_pending"
    t.integer  "customer_id"
    t.boolean  "request_finish"
    t.boolean  "request_waiter"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.boolean  "customer_table"
    t.boolean  "request_order"
    t.integer  "active_customer_id"
    t.string   "note"
  end

  add_index "tables", ["active_user_id"], name: "index_tables_on_active_user_id", using: :btree
  add_index "tables", ["company_id"], name: "index_tables_company_id", using: :btree
  add_index "tables", ["company_id"], name: "index_tables_on_company_id", using: :btree
  add_index "tables", ["hidden"], name: "index_tables_on_hidden", using: :btree
  add_index "tables", ["vendor_id"], name: "index_tables_on_vendor_id", using: :btree

  create_table "tables_users", id: false, force: true do |t|
    t.integer  "table_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_amounts", force: true do |t|
    t.integer  "surcharge_id"
    t.integer  "tax_id"
    t.float    "amount",       limit: 24
    t.integer  "vendor_id"
    t.boolean  "hidden"
    t.integer  "company_id"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  create_table "tax_items", force: true do |t|
    t.integer  "tax_id"
    t.integer  "item_id"
    t.integer  "booking_item_id"
    t.integer  "order_id"
    t.integer  "booking_id"
    t.integer  "settlement_id"
    t.float    "gro",                   limit: 24
    t.float    "net",                   limit: 24
    t.float    "tax",                   limit: 24
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "letter"
    t.integer  "surcharge_item_id"
    t.string   "name"
    t.string   "percent"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.boolean  "refunded"
    t.integer  "cost_center_id"
    t.integer  "category_id"
    t.integer  "statistic_category_id"
    t.datetime "hidden_at"
    t.integer  "user_id"
  end

  add_index "tax_items", ["booking_id"], name: "index_tax_items_on_booking_id", using: :btree
  add_index "tax_items", ["booking_item_id"], name: "index_tax_items_on_booking_item_id", using: :btree
  add_index "tax_items", ["company_id"], name: "index_tax_items_on_company_id", using: :btree
  add_index "tax_items", ["hidden"], name: "index_tax_items_on_hidden", using: :btree
  add_index "tax_items", ["item_id"], name: "index_tax_items_on_item_id", using: :btree
  add_index "tax_items", ["order_id"], name: "index_tax_items_on_order_id", using: :btree
  add_index "tax_items", ["settlement_id"], name: "index_tax_items_on_settlement_id", using: :btree
  add_index "tax_items", ["surcharge_item_id"], name: "index_tax_items_on_surcharge_item_id", using: :btree
  add_index "tax_items", ["tax_id"], name: "index_tax_items_on_tax_id", using: :btree
  add_index "tax_items", ["vendor_id"], name: "index_tax_items_on_vendor_id", using: :btree

  create_table "taxes", force: true do |t|
    t.float    "percent",                limit: 24
    t.string   "name"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "letter"
    t.string   "color"
    t.boolean  "hidden"
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.boolean  "statistics_by_category",            default: false
    t.boolean  "include_in_statistics",             default: false
    t.integer  "hidden_by"
    t.datetime "hidden_at"
  end

  add_index "taxes", ["company_id"], name: "index_taxes_company_id", using: :btree

  create_table "user_logins", force: true do |t|
    t.integer  "company_id"
    t.integer  "vendor_id"
    t.integer  "user_id"
    t.datetime "login"
    t.datetime "logout"
    t.integer  "duration"
    t.float    "hourly_rate",    limit: 24
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.string   "ip"
    t.boolean  "auto_logout"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "log_by_user_id"
  end

  create_table "user_messages", force: true do |t|
    t.integer  "sender_id"
    t.integer  "receipient_id"
    t.integer  "reply_id"
    t.boolean  "displayed"
    t.string   "subject"
    t.text     "body"
    t.string   "type"
    t.integer  "vendor_id"
    t.integer  "company_id"
    t.boolean  "hidden"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: true do |t|
    t.string   "login"
    t.string   "password"
    t.string   "title"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "role_id"
    t.string   "color"
    t.string   "language"
    t.boolean  "active",                               default: true
    t.boolean  "hidden",                               default: false
    t.integer  "company_id"
    t.integer  "screenlock_timeout",                   default: -1
    t.boolean  "automatic_printing"
    t.boolean  "onscreen_keyboard_enabled",            default: true
    t.string   "current_ip"
    t.datetime "last_active_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.boolean  "audio"
    t.string   "email"
    t.boolean  "confirmation_user"
    t.integer  "role_weight"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.integer  "default_vendor_id"
    t.string   "advertising_url"
    t.integer  "advertising_timeout",                  default: -1
    t.float    "hourly_rate",               limit: 24
    t.integer  "maximum_shift_duration",               default: 9999
    t.integer  "current_settlement_id"
    t.boolean  "track_time"
    t.string   "layout",                               default: "auto"
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["hidden"], name: "index_users_on_hidden", using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  create_table "users_vendors", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "vendor_id"
  end

  create_table "vendor_printers", force: true do |t|
    t.string   "name"
    t.string   "path"
    t.integer  "company_id"
    t.boolean  "hidden"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "copies",                default: 1
    t.integer  "vendor_id"
    t.string   "print_button_filename"
    t.integer  "codepage"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.integer  "baudrate",              default: 9600
    t.boolean  "pulse_tickets"
    t.boolean  "pulse_receipt"
    t.string   "ticket_ad",             default: ""
    t.boolean  "cut_every_ticket"
    t.boolean  "one_ticket_per_piece"
  end

  add_index "vendor_printers", ["company_id"], name: "index_vendor_printers_on_company_id", using: :btree

  create_table "vendors", force: true do |t|
    t.string   "name",                                         default: "Bill Gastro"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.integer  "largest_order_number",                         default: 0
    t.string   "unused_order_numbers",        limit: 1000,     default: "--- []\n"
    t.string   "country"
    t.integer  "time_offset",                                  default: 0
    t.text     "resources_cache",             limit: 16777215
    t.string   "res_fetch_url"
    t.string   "res_confirm_url"
    t.boolean  "use_order_numbers",                            default: true
    t.integer  "company_id"
    t.boolean  "active",                                       default: true
    t.boolean  "hidden"
    t.binary   "rlogo_header"
    t.binary   "rlogo_footer"
    t.boolean  "ticket_item_separator",                        default: true
    t.boolean  "ticket_wide_font",                             default: true
    t.boolean  "ticket_tall_font",                             default: true
    t.boolean  "ticket_display_time_order",                    default: true
    t.text     "receipt_header_blurb"
    t.text     "receipt_footer_blurb"
    t.text     "invoice_header_blurb"
    t.text     "invoice_footer_blurb"
    t.string   "unused_booking_numbers",      limit: 10000,    default: "--- []\n"
    t.integer  "largest_booking_number",                       default: 0
    t.boolean  "use_booking_numbers",                          default: true
    t.integer  "max_tables"
    t.integer  "max_rooms"
    t.integer  "max_articles"
    t.integer  "max_options"
    t.integer  "max_users"
    t.integer  "max_categories"
    t.string   "email"
    t.boolean  "remote_orders"
    t.integer  "update_tables_interval",                       default: 19
    t.integer  "update_item_lists_interval",                   default: 31
    t.integer  "update_resources_interval",                    default: 127
    t.integer  "automatic_printing_interval",                  default: 31
    t.string   "hash_id"
    t.integer  "largest_settlement_number",                    default: 0
    t.string   "unused_settlement_numbers",   limit: 1000,     default: "--- []\n"
    t.boolean  "use_settlement_numbers",                       default: true
    t.boolean  "enable_technician_emails",                     default: false
    t.string   "technician_email"
    t.integer  "hidden_by"
    t.datetime "hidden_at"
    t.boolean  "history_print"
    t.string   "branding",                    limit: 5000,     default: "--- {}\n"
    t.string   "identifier"
    t.integer  "ticket_space_top",                             default: 5
    t.text     "public_holidays"
    t.boolean  "one_ticket_per_piece"
  end

end
