class AdjustWebpushEndpointLength < ActiveRecord::Migration
  def change
    change_column :users, :webpush_endpoint, :text
  end
end
