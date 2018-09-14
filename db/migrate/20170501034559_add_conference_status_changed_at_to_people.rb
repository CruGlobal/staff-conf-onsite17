class AddConferenceStatusChangedAtToPeople < ActiveRecord::Migration
  def change
    add_column :people, :conference_status_changed_at, :datetime
  end
end
