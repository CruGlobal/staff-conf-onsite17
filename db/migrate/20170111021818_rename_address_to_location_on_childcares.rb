class RenameAddressToLocationOnChildcares < ActiveRecord::Migration
  def change
    rename_column :childcares, :address, :location
  end
end
