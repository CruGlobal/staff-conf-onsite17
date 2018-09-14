class CreateChargeableStaffNumbers < ActiveRecord::Migration
  def change
    create_table :chargeable_staff_numbers do |t|
      t.string :staff_number
      t.timestamps null: false
    end

    add_index :chargeable_staff_numbers, :staff_number
  end
end
