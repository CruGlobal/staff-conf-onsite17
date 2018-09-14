require 'test_helper'

class HousingUnit::FormTest < IntegrationTest
  include Support::HousingUnit

  before { prepare_for_testing }

  test '#form navigation to edit' do
    navigate_to_housing_units
    within("tr#housing_unit_#{@housing_facility.id}"){ click_link 'Edit' }

    assert_page_title 'Edit Housing Unit'
  end

  test '#form navigation to new' do
    navigate_to_housing_units
    click_link 'New Housing Unit'

    assert_page_title 'New Housing Unit'
  end

  test '#form fields' do
    visit_housing_unit :edit

    assert_edit_fields :name, record: @housing_unit

    assert_active_admin_comments
  end

  test '#new record creation' do
    visit_housing_unit :new

    attrs = attributes_for :housing_unit

    assert_difference -> { @housing_facility.housing_units.count } do
      fill_in 'Name', with: attrs[:name]

      click_button 'Create Housing unit'
    end
  end
end
