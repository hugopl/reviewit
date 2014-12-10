class AddGitlabCiSupport < ActiveRecord::Migration
  def change
    add_column :projects, :gitlab_ci_project_url, :string
    add_column :projects, :gitlab_ci_token, :string

    add_column :patches, :gitlab_ci_hash, :string
  end
end
