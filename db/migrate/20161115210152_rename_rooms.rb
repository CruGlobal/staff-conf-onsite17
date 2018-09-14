class RenameRooms < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up   { rename_table :rooms, :housing_units }
      dir.down { rename_table :housing_units, :rooms }
    end
  end
end
