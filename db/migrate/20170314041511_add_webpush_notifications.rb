class AddWebpushNotifications < ActiveRecord::Migration
  def change
    add_column :users, :webpush_endpoint, :string
    add_column :users, :webpush_auth, :string
    add_column :users, :webpush_p256dh, :string
  end
end
