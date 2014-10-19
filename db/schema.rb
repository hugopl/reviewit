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

ActiveRecord::Schema.define(version: 20141003232638) do

  create_table "comments", force: true do |t|
    t.integer  "user_id",                 null: false
    t.integer  "patch_id"
    t.text     "content",    default: "", null: false
    t.integer  "location",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["patch_id"], name: "index_comments_on_patch_id"

  create_table "merge_requests", force: true do |t|
    t.integer  "project_id"
    t.integer  "owner_id"
    t.integer  "reviewer_id"
    t.integer  "status",         default: 0, null: false
    t.string   "target_branch",              null: false
    t.string   "subject",                    null: false
    t.string   "commit_message",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merge_requests", ["owner_id"], name: "index_merge_requests_on_owner_id"
  add_index "merge_requests", ["project_id"], name: "index_merge_requests_on_project_id"
  add_index "merge_requests", ["reviewer_id"], name: "index_merge_requests_on_reviewer_id"

  create_table "patches", force: true do |t|
    t.integer  "merge_request_id"
    t.text     "diff",             default: "", null: false
    t.text     "integration_log"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "patches", ["merge_request_id"], name: "index_patches_on_merge_request_id"

  create_table "projects", force: true do |t|
    t.string   "name",                     null: false
    t.string   "description", default: "", null: false
    t.string   "repository",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_users", id: false, force: true do |t|
    t.integer "project_id", null: false
    t.integer "user_id",    null: false
  end

  add_index "projects_users", ["project_id", "user_id"], name: "index_projects_users_on_project_id_and_user_id", unique: true
  add_index "projects_users", ["project_id"], name: "index_projects_users_on_project_id"
  add_index "projects_users", ["user_id"], name: "index_projects_users_on_user_id"

  create_table "users", force: true do |t|
    t.string   "name",                                null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "api_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
