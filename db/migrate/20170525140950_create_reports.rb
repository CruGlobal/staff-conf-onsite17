class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :category, null: false
      t.string :name, null: false
      t.text :query, null: false
      t.string :role, null: false, default: 'general'

      t.timestamps null: false
    end
  end
end
