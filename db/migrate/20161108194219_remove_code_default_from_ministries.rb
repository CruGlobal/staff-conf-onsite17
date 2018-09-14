class RemoveCodeDefaultFromMinistries < ActiveRecord::Migration
  def change
    change_column_default :ministries, :code, nil
  end
end
