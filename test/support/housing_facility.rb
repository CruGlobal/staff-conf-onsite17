module Support
  module HousingFacility
    def prepare_for_testing
      @user = create_login_user
      @housing_facility = create :housing_facility_with_units
    end

    def visit_housing_facility(action)
      case action
      when :index
        visit housing_facilities_path
      when :show
        visit housing_facility_path(@housing_facility)
      when :edit
        visit edit_housing_facility_path(@housing_facility)
      when :new
        visit new_housing_facility_path
      end
    end

    def navigate_to_housing_facility(action)
      visit root_path
      click_link 'Housing Facilities'

      case action
      when :show
        select_housing_facility_action 'View'
      when :edit
        select_housing_facility_action 'Edit'
      when :new
        click_link 'New Housing Facility'
      end
    end

    private

    def select_housing_facility_action(text)
      within("tr#housing_facility_#{@housing_facility.id}") { click_link text }
    end
  end
end