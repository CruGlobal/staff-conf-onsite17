class ChangeHousingUnitNumberToString < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        change_column :housing_units, :number, :string
        rename_column :housing_units, :number, :name
      end

      dir.down do
        rename_column :housing_units, :name, :number
        change_column :housing_units, :number, :integer
      end
    end
  end
end
