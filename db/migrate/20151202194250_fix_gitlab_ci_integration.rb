class FixGitlabCiIntegration < ActiveRecord::Migration
  def change
    add_column :patches, :gitlab_ci_build, :integer
    add_index :patches, :gitlab_ci_hash

    remove_column :projects, :gitlab_ci_token
  end
end
