class AddCsuAttributesToHousingFacilities < ActiveRecord::Migration
  def change
    add_column :housing_facilities, :csu_dorm_code, :string
    add_column :housing_facilities, :csu_dorm_block, :string
  end
end
