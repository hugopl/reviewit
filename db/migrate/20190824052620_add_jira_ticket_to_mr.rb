class AddJiraTicketToMr < ActiveRecord::Migration[5.2]
  def change
    change_table :merge_requests, bulk: true do |t|
      t.string :jira_ticket
      t.string :jira_url
    end

    MergeRequest.all.each do |mr|
      mr.patch.send(:update_jira_ticket, silent: true)
    end
  end
end
