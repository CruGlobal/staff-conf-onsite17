class RemoveCostTypeDefaultFromCostAdjustments < ActiveRecord::Migration
  def change
    change_column_default :cost_adjustments, :cost_type, nil
  end
end
