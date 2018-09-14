require 'test_helper'

class HousingFacility::ShowTest < IntegrationTest
  include Support::HousingFacility

  before { prepare_for_testing }

  test '#show navigation' do
    navigate_to_housing_facility :show

    assert_page_title @housing_facility.name
  end

  test '#show details' do
    visit_housing_facility :show

    within('.panel', text: 'Housing Facility Details') do
      assert_show_rows :name, :housing_type, :cost_code, :cafeteria, :city,
                       :state, :street, :zip, :created_at, :updated_at,
                       selector: "#attributes_table_housing_facility_#{@housing_facility.id}"
    end
  end
end
