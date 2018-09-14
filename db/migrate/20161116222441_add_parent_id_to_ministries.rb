class AddParentIdToMinistries < ActiveRecord::Migration
  def change
    add_column :ministries, :parent_id, :integer, index: true
    add_foreign_key :ministries, :ministries, column: :parent_id, primary_key: :id
    add_index :ministries, :parent_id
  end
end
