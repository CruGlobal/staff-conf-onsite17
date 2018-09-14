class AddTypeToHousingFacilities < ActiveRecord::Migration
  def change
    add_column :housing_facilities, :housing_type, :integer, null: false, default: 0
  end
end
