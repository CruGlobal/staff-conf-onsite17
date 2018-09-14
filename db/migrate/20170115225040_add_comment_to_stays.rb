class AddCommentToStays < ActiveRecord::Migration
  def change
    add_column :stays, :comment, :text
  end
end
