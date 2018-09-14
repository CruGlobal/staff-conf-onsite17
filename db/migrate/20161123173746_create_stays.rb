class CreateStays < ActiveRecord::Migration
  def change
    create_table :stays do |t|
      t.references :person, index: true, foreign_key: true, null: false
      t.references :housing_unit, index: true, foreign_key: true
      t.date :arrived_at
      t.date :departed_at
      t.boolean :single_occupancy, default: false, null: false
      t.boolean :no_charge, default: false, null: false
      t.boolean :waive_minimum, default: false, null: false
      t.integer :percentage, default: 100, null: false

      t.timestamps null: false
    end
  end
end
