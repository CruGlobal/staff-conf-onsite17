class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.string :phone
      t.string :city
      t.string :state
      t.string :zip
      t.string :street
      t.string :country_code, limit: 2

      t.timestamps
    end
  end
end
