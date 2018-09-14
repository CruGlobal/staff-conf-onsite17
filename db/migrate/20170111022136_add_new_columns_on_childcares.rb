class AddNewColumnsOnChildcares < ActiveRecord::Migration
  def change
    rename_column :childcares, :title, :name

    remove_column :childcares, :start_date, :date
    remove_column :childcares, :end_date, :date
    remove_column :childcares, :cost, :integer

    add_column :childcares, :room, :string
  end
end
