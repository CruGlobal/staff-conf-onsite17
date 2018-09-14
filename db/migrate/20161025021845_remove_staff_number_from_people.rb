class RemoveStaffNumberFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :staff_number, :string
  end
end
