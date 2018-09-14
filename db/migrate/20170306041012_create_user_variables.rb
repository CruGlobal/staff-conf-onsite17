class CreateUserVariables < ActiveRecord::Migration
  def change
    create_table :user_variables do |t|
      t.string :code,        index: true, null: false, unique: true
      t.string :short_name,  index: true, null: false, unique: true
      t.integer :value_type,              null: false
      t.string :value,                    null: false
      t.text :description

      t.timestamps null: false
    end
  end
end
