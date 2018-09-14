class Import::UpdateFamilyFromImport < ApplicationService
  # +Family+
  attr_accessor :family

  # +Import::Person+
  attr_accessor :import

  def call
    update_family
    update_housing_preference
  end

  private

  def update_family
    family.assign_attributes(
      last_name: import.last_name,
      staff_number: import.staff_number,
      city: import.city,
      state: import.state,
      zip: import.zip,
      address1: import.address1,
      address2: import.address2,
      country_code: import.country_code
    )
  end

  def update_housing_preference
    housing_preference.assign_attributes(
      housing_type: import.housing_type,
      single_room: import.housing_single_room == 'Yes',
      roommates: import.housing_roommates_details,
      accepts_non_air_conditioned: import.housing_accepts_non_ac,
      location1: import.housing_location1,
      location2: import.housing_location2,
      location3: import.housing_location3,
      comment: import.housing_comment
    )

    update_housing_preference_counts
  end

  def update_housing_preference_counts
    housing_preference.assign_attributes(
      beds_count: import.housing_beds_count.to_i,
      children_count: import.housing_children_count.to_i,
      bedrooms_count: import.housing_bedrooms_count.to_i
    )
  end

  def housing_preference
    family.housing_preference || family.build_housing_preference
  end
end
