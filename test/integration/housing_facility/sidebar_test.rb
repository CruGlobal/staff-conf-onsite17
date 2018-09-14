require 'test_helper'

class HousingFacility::SidebarTest < IntegrationTest
  include Support::HousingFacility

  before { prepare_for_testing }
  after  { assert_units_sidebar }

  [:show, :edit].each do |action|
    test("sidebar #{action}") { visit_housing_facility action }
  end

  private

  def assert_units_sidebar
    within('#units_sidebar_section') do
      assert_selector('h4 strong a',
                     text: "All Units (#{@housing_facility.housing_units.size})")

      assert_selector('ul.units_list li a', 
                     text: @housing_facility.housing_units.sample.name)
    end
  end
end