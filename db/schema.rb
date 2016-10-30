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

ActiveRecord::Schema.define(version: 20160624085115) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.integer  "created_by_id"
    t.string   "name",                      default: "", null: false
    t.string   "industry"
    t.string   "location"
    t.integer  "size",            limit: 2, default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "primary_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.string   "name"
    t.string   "job"
    t.integer  "project_id"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "order_value",                         default: 0
    t.decimal  "price",       precision: 6, scale: 2, default: 0.0
    t.date     "added_date",                          default: '2016-06-24'
  end

  add_index "expenses", ["project_id"], name: "index_expenses_on_project_id", using: :btree

  create_table "project_tags", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "project_tags", ["user_id"], name: "index_project_tags_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "created_by_id"
    t.string   "name"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "project_tag",                           default: "0"
    t.decimal  "gross_revenue", precision: 8, scale: 2, default: 0.0
    t.integer  "category"
  end

  add_index "projects", ["client_id"], name: "index_projects_on_client_id", using: :btree
  add_index "projects", ["created_by_id"], name: "index_projects_on_created_by_id", using: :btree

  create_table "resource_timelines", force: :cascade do |t|
    t.integer  "resource_id"
    t.integer  "timeline_id"
    t.decimal  "hours",       precision: 6, scale: 2, default: 0.0
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "resource_timelines", ["resource_id"], name: "index_resource_timelines_on_resource_id", using: :btree
  add_index "resource_timelines", ["timeline_id"], name: "index_resource_timelines_on_timeline_id", using: :btree

  create_table "resources", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "role"
    t.string   "name"
    t.decimal  "client_rate",   precision: 6, scale: 2, default: 0.0
    t.decimal  "resource_rate", precision: 6, scale: 2, default: 0.0
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "is_estimated",                          default: true
    t.integer  "order_value",                           default: 0
  end

  add_index "resources", ["project_id"], name: "index_resources_on_project_id", using: :btree

  create_table "timelines", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_estimated", default: true
  end

  add_index "timelines", ["project_id"], name: "index_timelines_on_project_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "",    null: false
    t.string   "encrypted_password",               default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "username"
    t.string   "name"
    t.string   "org_name"
    t.text     "tags"
    t.boolean  "super",                            default: false
    t.boolean  "admin",                            default: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",                default: 0
    t.string   "access_token"
    t.string   "organisation_name"
    t.integer  "step",                   limit: 2, default: 0
    t.integer  "user_type",              limit: 2, default: 0
    t.integer  "created_by_id",                    default: 0
    t.string   "invite_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "expenses", "projects"
end
