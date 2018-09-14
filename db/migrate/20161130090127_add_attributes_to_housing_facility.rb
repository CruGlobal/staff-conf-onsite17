class AddAttributesToHousingFacility < ActiveRecord::Migration
  def change
    add_reference :housing_facilities, :cost_code, index: true, foreign_key: true
    add_column :housing_facilities, :cafeteria, :string
  end
end
