class CreateLockedBranchesTable < ActiveRecord::Migration
  def change
    create_table :locked_branches do |t|
      t.references :project, null: false
      t.integer :who_id, null: false
      t.string :branch, null: false
      t.timestamps
    end

    add_index :locked_branches, %i(branch project_id), unique: true
  end
end
