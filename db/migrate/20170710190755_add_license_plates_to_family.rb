class AddLicensePlatesToFamily < ActiveRecord::Migration
  def change
    add_column :families, :license_plates, :string
    add_column :families, :handicap, :boolean
  end
end
