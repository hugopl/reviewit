class AddSettingsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.column :notify_mr_creation_by_email, :boolean, default: true, null: false
      t.column :notify_mr_creation_by_webpush, :boolean, default: true, null: false
      t.column :notify_mr_update_by_email, :boolean, default: true, null: false
      t.column :notify_mr_update_by_webpush, :boolean, default: true, null: false
      t.column :notify_mr_ci_by_webpush, :boolean, default: true, null: false
      t.column :notify_mr_status_by_webpush, :boolean, default: true, null: false
    end
  end
end
