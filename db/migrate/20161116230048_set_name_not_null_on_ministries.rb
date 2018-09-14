class SetNameNotNullOnMinistries < ActiveRecord::Migration
  def change
    change_column_null :ministries, :name, false
  end
end
