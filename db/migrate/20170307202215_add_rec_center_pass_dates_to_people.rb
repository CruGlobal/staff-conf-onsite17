class AddRecCenterPassDatesToPeople < ActiveRecord::Migration
  def change
    add_column :people, :rec_center_pass_started_at, :date
    add_column :people, :rec_center_pass_expired_at, :date
  end
end
