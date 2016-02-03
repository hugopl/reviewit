class RemoveCoolUndocumentedFeature < ActiveRecord::Migration
  def change
    remove_column :projects, :summary_addons
  end
end
