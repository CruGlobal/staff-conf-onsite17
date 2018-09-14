class AddPrimaryPersonIdToFamily < ActiveRecord::Migration
  def change
    add_column :families, :primary_person_id, :integer
  end
end
