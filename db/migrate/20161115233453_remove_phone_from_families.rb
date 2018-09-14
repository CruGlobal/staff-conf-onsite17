class RemovePhoneFromFamilies < ActiveRecord::Migration
  def change
    remove_column :families, :phone, :string
  end
end
