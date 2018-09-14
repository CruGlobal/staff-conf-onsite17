class AddStaffNumberToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :staff_number, :string

    reversible do |dir|
      dir.up do
        Family.update_all staff_number: '<UNKNOWN>'
      end
    end
  end
end
