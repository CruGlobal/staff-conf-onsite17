class AddCostTypeToCostAdjustments < ActiveRecord::Migration
  def change
    add_column :cost_adjustments, :cost_type, :integer, null: false, default: 0
  end
end
