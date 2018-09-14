class SetGuidNotNullOnUsers < ActiveRecord::Migration
  def change
    User.destroy_all
    change_column :users, :guid, :string, null: false
  end
end
