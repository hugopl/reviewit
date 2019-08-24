class AddLikesToMergeRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      t.references :user, null: false
      t.references :merge_request, null: false
      t.timestamps null: false
    end

    add_index :likes, %i(user_id merge_request_id), unique: true
  end
end
