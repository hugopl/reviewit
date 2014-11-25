class FixHistoryEventsWhenAttribute < ActiveRecord::Migration
  def change
    change_column :history_events, :when, :datetime, null: true
    change_column_default :history_events, :when, :null
  end
end
