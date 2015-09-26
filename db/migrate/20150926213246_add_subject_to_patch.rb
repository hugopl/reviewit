class AddSubjectToPatch < ActiveRecord::Migration
  def up
    add_column :patches, :subject, :text

    Patch.all.each do |patch|
      lines = patch.commit_message.lines
      patch.subject = lines.shift
      patch.commit_message = lines.join
      patch.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
