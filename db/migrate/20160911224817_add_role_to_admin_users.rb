class AddRoleToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :role, :string, default: 'general', index: true
  end
end
