class CreateHousingPreferences < ActiveRecord::Migration
  def change
    create_table :housing_preferences do |t|
      t.references :family, null: false
      t.integer :housing_type, null: false

      t.string :location1
      t.string :location2
      t.string :location3
      t.integer :beds_count
      t.text :roommates
      t.date :confirmed_at

      # If housing_type == Apartment
      t.integer :children_count
      t.integer :bedrooms_count

      t.timestamps null: false
    end
  end
end
