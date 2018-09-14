class MakeLastNameNonNullOnFamilies < ActiveRecord::Migration
  def change
    change_column_null :families, :last_name, false
  end
end
