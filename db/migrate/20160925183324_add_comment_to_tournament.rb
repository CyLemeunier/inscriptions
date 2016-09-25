class AddCommentToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :comment, :text
  end
end
