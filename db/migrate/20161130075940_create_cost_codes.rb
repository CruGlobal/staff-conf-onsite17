class CreateCostCodes < ActiveRecord::Migration
  def change
    create_table :cost_codes do |t|
      t.string :name, null: false, unique: true
      t.text :description
      t.integer :min_days, null: false, default: 1

      t.timestamps null: false
    end
  end
end
