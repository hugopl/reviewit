class AddJiraIntegration < ActiveRecord::Migration
  def change
    add_column :projects, :jira_username, :string
    add_column :projects, :jira_password, :string
    add_column :projects, :jira_api_url, :string
    add_column :projects, :jira_ticket_regexp, :string
  end
end
