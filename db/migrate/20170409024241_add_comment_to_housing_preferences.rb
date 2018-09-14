class AddCommentToHousingPreferences < ActiveRecord::Migration
  def change
    add_column :housing_preferences, :comment, :text
  end
end
