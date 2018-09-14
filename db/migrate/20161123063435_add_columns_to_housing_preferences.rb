class AddColumnsToHousingPreferences < ActiveRecord::Migration
  def change
    add_column :housing_preferences, :single_room, :boolean
    add_column :housing_preferences, :other_family, :string
    add_column :housing_preferences, :accepts_non_air_conditioned, :boolean
  end
end
