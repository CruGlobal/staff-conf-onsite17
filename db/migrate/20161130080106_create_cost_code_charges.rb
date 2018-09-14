class CreateCostCodeCharges < ActiveRecord::Migration
  def change
    create_table :cost_code_charges do |t|
      t.references :cost_code, index: true, foreign_key: true
      t.integer :max_days, default: 0
      t.integer :adult_cents, default: 0
      t.integer :teen_cents, default: 0
      t.integer :child_cents, default: 0
      t.integer :infant_cents, default: 0
      t.integer :child_meal_cents, default: 0
      t.integer :single_delta_cents, default: 0

      t.timestamps null: false

      t.index [:cost_code_id, :max_days], unique: true
    end
  end
end
