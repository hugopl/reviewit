class CreateTables < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :name
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string   :api_token, unique: true

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true

    create_table :projects do |t|
      t.string :name
      t.string :repository
      t.timestamps
    end

    create_table :projects_users, :id => false do |t|
      t.references :project, index: true
      t.references :user, index: true
    end

    add_index :projects_users, [:project_id, :user_id]

    create_table :merge_requests do |t|
      t.references :project, index: true
      t.references :user, index: true
      t.belongs_to :reviewer, :class_name => 'User'
      t.string :status
      t.timestamps
    end

    create_table :patches do |t|
      t.references :merge_request, index: true
      t.text       :diff
      t.timestamps
    end

    create_table :comments do |t|
      t.references :user
      t.references :patch, index: true
      t.text       :comment
      t.timestamps
    end
  end
end
