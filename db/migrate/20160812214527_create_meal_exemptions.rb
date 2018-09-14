class CreateMealExemptions < ActiveRecord::Migration
  def change
    create_table :meal_exemptions do |t|
      t.date :date
      t.references :person, foreign_key: true, index: true
      t.string :meal_type

      t.timestamps

      t.index [:person_id, :date, :meal_type], unique: true
    end
  end
end
