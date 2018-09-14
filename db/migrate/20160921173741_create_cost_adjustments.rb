class CreateCostAdjustments < ActiveRecord::Migration
  def change
    create_table :cost_adjustments do |t|
      t.references :person, index: true, foreign_key: true
      t.integer :cents, null: false
      t.text :description

      t.timestamps null: false
    end
  end
end
