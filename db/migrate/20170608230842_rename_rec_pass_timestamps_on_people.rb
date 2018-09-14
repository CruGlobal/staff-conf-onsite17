class RenameRecPassTimestampsOnPeople < ActiveRecord::Migration
  def change
    rename_column :people, :rec_center_pass_started_at, :rec_pass_start_at
    rename_column :people, :rec_center_pass_expired_at, :rec_pass_end_at
  end
end
