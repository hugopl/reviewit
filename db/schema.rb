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

ActiveRecord::Schema.define(version: 20180220011610) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.integer  "patch_id"
    t.text     "content",    default: "", null: false
    t.integer  "location",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["patch_id"], name: "index_comments_on_patch_id", using: :btree

  create_table "history_events", force: :cascade do |t|
    t.integer  "merge_request_id",             null: false
    t.integer  "who_id"
    t.datetime "when"
    t.string   "what",             limit: 255, null: false
  end

  add_index "history_events", ["merge_request_id"], name: "index_history_events_on_merge_request_id", using: :btree
  add_index "history_events", ["who_id"], name: "index_history_events_on_who_id", using: :btree

  create_table "locked_branches", force: :cascade do |t|
    t.integer  "project_id", null: false
    t.integer  "who_id",     null: false
    t.string   "branch",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locked_branches", ["branch", "project_id"], name: "index_locked_branches_on_branch_and_project_id", unique: true, using: :btree

  create_table "merge_requests", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "author_id"
    t.integer  "reviewer_id"
    t.integer  "status",                    default: 0, null: false
    t.string   "target_branch", limit: 255,             null: false
    t.string   "subject",       limit: 255,             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merge_requests", ["author_id"], name: "index_merge_requests_on_author_id", using: :btree
  add_index "merge_requests", ["project_id"], name: "index_merge_requests_on_project_id", using: :btree
  add_index "merge_requests", ["reviewer_id"], name: "index_merge_requests_on_reviewer_id", using: :btree

  create_table "patches", force: :cascade do |t|
    t.integer  "merge_request_id"
    t.text     "description",                  default: ""
    t.text     "commit_message",                               null: false
    t.text     "diff",                         default: "",    null: false
    t.boolean  "linter_ok",                    default: false, null: false
    t.text     "integration_log"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gitlab_ci_hash",   limit: 255
    t.integer  "gitlab_ci_status",             default: 0
    t.text     "subject"
    t.integer  "gitlab_ci_build"
  end

  add_index "patches", ["gitlab_ci_hash"], name: "index_patches_on_gitlab_ci_hash", using: :btree
  add_index "patches", ["merge_request_id"], name: "index_patches_on_merge_request_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                  limit: 255,              null: false
    t.string   "description",           limit: 255, default: "", null: false
    t.string   "repository",            limit: 255,              null: false
    t.string   "linter",                limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gitlab_ci_project_url", limit: 255
    t.text     "jira_username"
    t.text     "jira_password"
    t.text     "jira_api_url"
    t.text     "jira_ticket_regexp"
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id",    null: false
  end

  add_index "projects_users", ["project_id", "user_id"], name: "index_projects_users_on_project_id_and_user_id", unique: true, using: :btree
  add_index "projects_users", ["project_id"], name: "index_projects_users_on_project_id", using: :btree
  add_index "projects_users", ["user_id"], name: "index_projects_users_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255,                 null: false
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "api_token",                                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",                          default: "UTC"
    t.text     "webpush_endpoint"
    t.string   "webpush_auth"
    t.string   "webpush_p256dh"
  end

  add_index "users", ["api_token"], name: "index_users_on_api_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
