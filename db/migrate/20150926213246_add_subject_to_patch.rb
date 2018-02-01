class AddSubjectToPatch < ActiveRecord::Migration
  def up
    add_column :patches, :subject, :text

    Patch.all.each do |patch|
      convert_patch(patch)
      patch.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def convert_patch(patch)
    lines = patch.commit_message.lines
    patch.subject = lines.shift.strip
    patch.commit_message = lines.join.strip
    patch.diff = "From: #{patch.author.name} <#{patch.author.email}>\n" \
                 "Date: #{patch.created_at.rfc2822}\n" \
                 "Subject: [PATCH] #{patch.subject}\n" \
                 "\n" \
                 "#{patch.commit_message}\n" \
                 "\n" \
                 "#{patch.diff}\n" \
                 "-- \n" \
                 "2.5.3\n"
  end
end
