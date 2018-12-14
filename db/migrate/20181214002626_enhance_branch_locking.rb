class EnhanceBranchLocking < ActiveRecord::Migration[5.2]
  def change
    add_column :locked_branches, :reason, :text, null: false, default: ''
  end
end
