class AddGitLabCiStatus < ActiveRecord::Migration
  def change
    add_column :patches, :gitlab_ci_status, :int, default: 0
  end
end
