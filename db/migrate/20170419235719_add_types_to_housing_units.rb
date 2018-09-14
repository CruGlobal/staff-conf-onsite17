class AddTypesToHousingUnits < ActiveRecord::Migration
  def change
    add_column :housing_units, :occupancy_type, :string
    add_column :housing_units, :room_type, :string
  end
end
