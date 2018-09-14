class AddDatesToPeople < ActiveRecord::Migration
  def change
    add_column :people, :arrived_at, :date
    add_column :people, :departed_at, :date
  end
end
