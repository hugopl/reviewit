class SetReviewerOnAbandonedMergeRequests < ActiveRecord::Migration[5.2]
  def up
    MergeRequest.abandoned.each do |mr|
      reviewer_id = mr.history_events.where(what: 'abandoned the merge request').order(when: :desc).pluck(:who_id).first
      raise if reviewer_id.nil?

      mr.reviewer_id = reviewer_id
      mr.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
