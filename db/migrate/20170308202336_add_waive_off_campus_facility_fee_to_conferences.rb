class AddWaiveOffCampusFacilityFeeToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :waive_off_campus_facility_fee, :boolean
  end
end
