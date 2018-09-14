class AddImportTagToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :import_tag, :string
  end
end
