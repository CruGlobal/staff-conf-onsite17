class MakeCodeUniqueOnMinistries < ActiveRecord::Migration
  def change
    add_index :ministries, :code, unique: true
  end
end
