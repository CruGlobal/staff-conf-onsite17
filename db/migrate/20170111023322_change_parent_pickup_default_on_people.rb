class ChangeParentPickupDefaultOnPeople < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up   { change_column_default :people, :parent_pickup, true }
      dir.down { change_column_default :people, :parent_pickup, nil }
    end
  end
end
