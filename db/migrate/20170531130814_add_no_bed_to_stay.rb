class AddNoBedToStay < ActiveRecord::Migration
  def change
    add_column :stays, :no_bed, :boolean, null: false, default: false
  end
end
