class CreateConferences < ActiveRecord::Migration
  def change
    create_table :conferences do |t|
      t.integer :cents
      t.string :name
      t.text :description
      t.date :start_at
      t.date :end_at

      t.timestamps null: false
    end
  end
end
