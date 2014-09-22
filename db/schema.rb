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

ActiveRecord::Schema.define(version: 20140901120255) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: true do |t|
    t.string   "username"
    t.boolean  "is_super_admin"
    t.string   "email"
    t.integer  "mobile"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "address"
    t.string   "privilages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_hash"
    t.string   "password_salt"
  end

  create_table "calculations", force: true do |t|
    t.integer  "max_out"
    t.integer  "renew"
    t.float    "user_profit"
    t.float    "first_year"
    t.float    "minimum_product_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code_value"
    t.integer  "blanced_nodes_number"
    t.integer  "number_of_product_credit_cheques_"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cheques", force: true do |t|
    t.float    "value"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "codes", force: true do |t|
    t.string   "code"
    t.float    "value"
    t.date     "date_released"
    t.date     "expired_date"
    t.boolean  "verify"
    t.boolean  "valid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_id"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: true do |t|
    t.string   "name"
    t.integer  "phone"
    t.text     "address"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expenses", force: true do |t|
    t.date     "date"
    t.float    "value"
    t.boolean  "is_master"
    t.boolean  "is_money"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code_id"
    t.integer  "user_id"
    t.integer  "sale_id"
  end

  create_table "first_products", force: true do |t|
    t.float    "price"
    t.date     "date_of_price"
    t.boolean  "is_completed"
    t.date     "date_completed"
    t.boolean  "is_delivered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "product_id"
  end

  create_table "governorates", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
  end

  create_table "product_has_sales", force: true do |t|
    t.integer  "product_id"
    t.integer  "sale_id"
    t.float    "price"
    t.float    "real_price"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.text     "description"
    t.integer  "quantity"
    t.float    "real_price"
    t.float    "offer"
    t.date     "offer_expired_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_category_id"
    t.boolean  "is_featured"
    t.boolean  "is_best_seller"
  end

  create_table "regions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "governorate_id"
  end

  create_table "sales", force: true do |t|
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.boolean  "is_delivered"
  end

  create_table "slider_images", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sub_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  create_table "trees", force: true do |t|
    t.integer  "parent"
    t.integer  "left"
    t.integer  "right"
    t.integer  "virtual_right_count"
    t.integer  "virtual_left_count"
    t.integer  "total_left"
    t.integer  "total_right"
    t.integer  "virtual_credit"
    t.integer  "total_cheque_count"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "user_infos", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "address1"
    t.text     "address2"
    t.integer  "mobile"
    t.integer  "land_phone"
    t.integer  "postal_code"
    t.integer  "national_id"
    t.float    "longtude"
    t.float    "latitude"
    t.boolean  "gender"
    t.date     "birthdate"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "status_id"
    t.integer  "region_id"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.decimal  "master_credit"
    t.decimal  "product_credit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code_id"
    t.string   "password_hash"
    t.string   "password_salt"
  end

end
