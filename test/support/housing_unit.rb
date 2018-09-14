module Support
  module HousingUnit
    def prepare_for_testing
      @user = create_login_user
      @housing_facility = create :housing_facility_with_units
      @housing_unit = @housing_facility.housing_units.sample
    end

    def navigate_to_housing_facility
      visit root_path

      click_link 'Housing Facilities'
      within("tr#housing_facility_#{@housing_facility.id}"){ click_link 'View' }
    end

    def navigate_to_housing_units
      navigate_to_housing_facility
      click_link "All Units (#{@housing_facility.housing_units.size})"
    end

    def visit_housing_unit(action)
      case action
      when :index
        visit housing_facility_housing_units_path(@housing_facility)
      when :show
        visit housing_facility_housing_unit_path(@housing_facility, @housing_unit)
      when :edit
        visit edit_housing_facility_housing_unit_path(@housing_facility, @housing_unit)
      when :new
        visit new_housing_facility_housing_unit_path(@housing_facility)
      end
    end
  end
end