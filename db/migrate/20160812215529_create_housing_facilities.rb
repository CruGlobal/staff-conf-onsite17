class CreateHousingFacilities < ActiveRecord::Migration
  def change
    create_table :housing_facilities do |t|
      t.string :name
      t.string :city
      t.string :state
      t.string :zip
      t.string :street
      t.string :country_code, limit: 2

      t.timestamps
    end
  end
end
