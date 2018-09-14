class AddLastNameToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :last_name, :string

    reversible do |dir|
      dir.up do
        Family.update_all last_name: '<UNKNOWN>'
      end
    end
  end
end
