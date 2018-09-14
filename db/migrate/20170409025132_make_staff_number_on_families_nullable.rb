class MakeStaffNumberOnFamiliesNullable < ActiveRecord::Migration
  def change
    change_column_null :families, :staff_number, true
  end
end
