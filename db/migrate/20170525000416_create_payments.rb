class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :family,    null: false, index: true
      t.integer :price_cents,  null: false
      t.integer :payment_type, null: false, index: true
      t.integer :cost_type,    null: false, index: true
      t.string :business_unit
      t.string :operating_unit
      t.string :department_code
      t.string :project_code
      t.string :reference

      t.timestamps null: false
    end
  end
end
