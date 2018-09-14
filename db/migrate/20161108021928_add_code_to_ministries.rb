class AddCodeToMinistries < ActiveRecord::Migration
  def change
    add_column :ministries, :code, :string, default: '<deprecated>'
    change_column_null :ministries, :code, false
  end
end
