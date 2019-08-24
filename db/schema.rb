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

ActiveRecord::Schema.define(version: 2019_08_24_221104) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "patch_id", null: false
    t.text "content", default: "", null: false
    t.integer "location", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", limit: 2
    t.integer "reviewer_id"
    t.index ["patch_id"], name: "index_comments_on_patch_id"
  end

  create_table "history_events", id: :serial, force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.integer "who_id", null: false
    t.datetime "when", null: false
    t.string "what", limit: 255, null: false
    t.index ["merge_request_id"], name: "index_history_events_on_merge_request_id"
    t.index ["who_id"], name: "index_history_events_on_who_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "merge_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merge_request_id"], name: "index_likes_on_merge_request_id"
    t.index ["user_id", "merge_request_id"], name: "index_likes_on_user_id_and_merge_request_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "locked_branches", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "who_id", null: false
    t.string "branch", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reason", default: "", null: false
    t.index ["branch", "project_id"], name: "index_locked_branches_on_branch_and_project_id", unique: true
  end

  create_table "merge_requests", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "author_id", null: false
    t.integer "reviewer_id"
    t.integer "status", default: 0, null: false
    t.string "target_branch", limit: 255, null: false
    t.string "subject", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jira_ticket"
    t.string "jira_url"
    t.index ["author_id"], name: "index_merge_requests_on_author_id"
    t.index ["project_id"], name: "index_merge_requests_on_project_id"
    t.index ["reviewer_id"], name: "index_merge_requests_on_reviewer_id"
  end

  create_table "patches", id: :serial, force: :cascade do |t|
    t.integer "merge_request_id", null: false
    t.text "description", default: ""
    t.text "commit_message", null: false
    t.text "diff", default: "", null: false
    t.boolean "linter_ok", default: false, null: false
    t.text "integration_log"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gitlab_ci_hash", limit: 255
    t.integer "gitlab_ci_status", default: 0
    t.text "subject"
    t.integer "gitlab_ci_build"
    t.index ["gitlab_ci_hash"], name: "index_patches_on_gitlab_ci_hash"
    t.index ["merge_request_id"], name: "index_patches_on_merge_request_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "repository", limit: 255, null: false
    t.string "linter", limit: 255, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gitlab_ci_project_url", limit: 255
    t.text "jira_username"
    t.text "jira_password"
    t.text "jira_api_url"
    t.text "jira_ticket_regexp"
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.index ["project_id", "user_id"], name: "index_projects_users_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_projects_users_on_project_id"
    t.index ["user_id"], name: "index_projects_users_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "api_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone", default: "UTC"
    t.text "webpush_endpoint"
    t.string "webpush_auth"
    t.string "webpush_p256dh"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
