class AddJiraTicketToMr < ActiveRecord::Migration[5.2]
  def change
    add_column :merge_requests, :jira_ticket, :string
    add_column :merge_requests, :jira_url, :string

    MergeRequest.all.each do |mr|
      mr.patch.send(:update_jira_ticket, silent: true)
    end
  end
end
