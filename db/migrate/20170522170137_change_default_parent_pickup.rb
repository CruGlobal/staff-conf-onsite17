class ChangeDefaultParentPickup < ActiveRecord::Migration
  def change
    change_table :people do |t|
      t.change_default :parent_pickup, false
    end
  end
end
