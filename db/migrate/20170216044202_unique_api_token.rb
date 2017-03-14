class UniqueApiToken < ActiveRecord::Migration
  def change
    change_column :users, :api_token, :string, null: false
    add_index :users, :api_token, unique: true
  end
end
