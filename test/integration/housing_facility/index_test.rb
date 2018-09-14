require 'test_helper'

class HousingFacility::IndexTest < IntegrationTest
  include Support::HousingFacility

  before { prepare_for_testing }

  test '#index navigation' do
    navigate_to_housing_facility :index

    assert_page_title 'Housing Facilities'
  end

  test '#index filters' do
    visit_housing_facility :index

    within('.filter_form') do
      assert_text 'Name'
      assert_text 'Cost code'
      assert_text 'Cafeteria'
      assert_text 'Street'
      assert_text 'City'
      assert_text 'State'
      assert_text 'Country'
      assert_text 'Zip Code'
      assert_text 'Created at'
      assert_text 'Updated at'
    end
  end

  test '#index columns' do
    visit_housing_facility :index

    assert_index_columns :selectable, :name, :housing_type, :cost_code,
                         :cafeteria, :units, :created_at, :updated_at, :actions
  end

  test '#index items' do
    visit_housing_facility :index

    within('#index_table_housing_facilities') do
      assert_selector "#housing_facility_#{@housing_facility.id}"
    end
  end

end
