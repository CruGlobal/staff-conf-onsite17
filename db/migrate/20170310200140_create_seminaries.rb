class CreateSeminaries < ActiveRecord::Migration
  def change
    create_table :seminaries do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :course_price_cents, default: 0, null: false

      t.timestamps null: false
    end

    add_index :seminaries, :code, unique: true
  end
end
