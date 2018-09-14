class RenameCentsColumnOnCostAdjustments < ActiveRecord::Migration
  def change
    rename_column :cost_adjustments, :cents, :price_cents
    change_column :cost_adjustments, :price_cents, :integer, null: false
  end
end
