class FixCommentLocations < ActiveRecord::Migration
  def up
    Comment.where('location > 0').update_all('location = (location - 1)')
  end

  def down
    Comment.where('location > 0').update_all('location = (location + 1)')
  end
end
