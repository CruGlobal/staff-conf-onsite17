class AddStaffConferenceToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :staff_conference, :boolean, null: false, default: false, index: true
  end
end
