class AddPercentToCostAdjustments < ActiveRecord::Migration
  def change
    change_column_null :cost_adjustments, :price_cents, true

    add_column :cost_adjustments, :percent, :decimal, precision: 5, scale: 2
  end
end
