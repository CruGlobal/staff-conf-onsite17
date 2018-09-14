class AddOnCampusToHousingFacilities < ActiveRecord::Migration
  def change
    add_column :housing_facilities, :on_campus, :boolean
  end
end
