class FixNullConstraints < ActiveRecord::Migration[5.2]
  def change
    change_column_null :comments, :patch_id, false
    change_column_null :comments, :created_at, false
    change_column_null :comments, :updated_at, false

    change_column_null :history_events, :who_id, false
    change_column_null :history_events, :when, false

    change_column_null :locked_branches, :created_at, false
    change_column_null :locked_branches, :updated_at, false

    change_column_null :merge_requests, :project_id, false
    change_column_null :merge_requests, :author_id, false
    change_column_null :merge_requests, :created_at, false
    change_column_null :merge_requests, :updated_at, false

    change_column_null :patches, :merge_request_id, false
    change_column_null :patches, :created_at, false
    change_column_null :patches, :updated_at, false

    change_column_null :projects, :created_at, false
    change_column_null :projects, :updated_at, false

    change_column_null :users, :created_at, false
    change_column_null :users, :updated_at, false
  end
end
