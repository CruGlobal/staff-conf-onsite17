class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :housing_facility, foreign_key: true
      t.integer :number

      t.timestamps

      t.index [:housing_facility_id, :number], unique: true
    end
  end
end
