class AddHistoryEventsTable < ActiveRecord::Migration
  def change
    create_table(:history_events) do |t|
      t.references :merge_request, index: true, null: false
      t.belongs_to :who,           index: true, class_name: 'User'
      t.datetime   :when,          null: false, default: Time.now
      t.string     :what,          null: false
    end
  end
end
