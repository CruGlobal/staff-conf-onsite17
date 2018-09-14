class MakeStaffNumberNonNullOnFamilies < ActiveRecord::Migration
  def change
    change_column_null :families, :staff_number, false
  end
end
