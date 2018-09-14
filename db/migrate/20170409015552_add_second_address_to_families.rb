class AddSecondAddressToFamilies < ActiveRecord::Migration
  def change
    rename_column :families, :street, :address1
    add_column :families, :address2, :string
  end
end
