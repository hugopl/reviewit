class AddBlockerIssuesToComments < ActiveRecord::Migration
  def change
    add_column :comments, :status, :integer, limit: 1
    add_column :comments, :reviewer_id, :integer
  end
end
