class FixCommentLocations < ActiveRecord::Migration
  def up
    Comment.update_all('location = (location - 1)')
  end

  def down
    Comment.update_all('location = (location + 1)')
  end
end
