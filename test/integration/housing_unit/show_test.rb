require 'test_helper'

class HousingUnit::ShowTest < IntegrationTest
  include Support::HousingUnit

  before { prepare_for_testing }

  test '#show navigation' do
    navigate_to_housing_facility
    within('#units_sidebar_section'){ click_link @housing_unit.name }

    assert_page_title "#{@housing_facility.name}: Unit #{@housing_unit.name}"
  end

  test '#show details' do
    visit_housing_unit :show

    within('.panel', text: 'Housing Unit Details') do
      assert_show_rows :name, :housing_facility, :housing_type, :created_at,
                       :updated_at,
                       selector: "#attributes_table_housing_unit_#{@housing_unit.id}"
    end
  end

  test '#show assignments empty' do
    visit_housing_unit :show

    within('.panel.stays', text: "Assignments (0)") { assert_text 'None' }
  end

  test '#show assignments' do
    stay = create :stay, housing_unit: @housing_unit

    visit_housing_unit :show

    within('.panel.stays', text: "Assignments (#{@housing_unit.stays.size})") do
      assert_selector 'ol li a', text: stay.person.full_name

      dates = "#{stay.arrived_at.to_s(:db)} to #{stay.departed_at.to_s(:db)}"
      assert_text dates
    end
  end
end
