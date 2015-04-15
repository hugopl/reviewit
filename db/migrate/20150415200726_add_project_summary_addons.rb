class AddProjectSummaryAddons < ActiveRecord::Migration
  def change
    add_column :projects, :summary_addons, :text
  end
end
