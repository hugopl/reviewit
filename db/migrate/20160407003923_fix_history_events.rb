class FixHistoryEvents < ActiveRecord::Migration
  def up
    change_column :history_events, :when, :datetime
    change_column_default :history_events, :when, nil
  end

  def down
    change_column :history_events, :when, :datetime, null: true
    change_column_default :history_events, :when, :null
  end
end
