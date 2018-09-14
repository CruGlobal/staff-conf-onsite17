class CreateChildcare < ActiveRecord::Migration
  def change
    create_table :childcares do |t|
      t.string :title
      t.string :teachers
      t.string :address
      t.integer :cost
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
