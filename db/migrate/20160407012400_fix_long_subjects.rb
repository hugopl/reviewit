class FixLongSubjects < ActiveRecord::Migration
  def up
    MergeRequest.where('LENGTH(subject) > 255').each do |mr|
      mr.subject = mr.subject[0...255]
      mr.save!
    end
  end

  def down
  end
end
