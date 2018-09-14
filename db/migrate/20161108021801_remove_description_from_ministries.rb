class RemoveDescriptionFromMinistries < ActiveRecord::Migration
  def change
    remove_column :ministries, :description, :text
  end
end
