require 'test_helper'

class HousingUnit::SidebarTest < IntegrationTest
  include Support::HousingUnit

  before { prepare_for_testing }
  after  { assert_link_to_housing_facility }

  # tests for presence of sidebar with link to @housing_facility
  # on each of these pages
  [:index, :show, :new, :edit].each do |action|
    test("#sidebar #{action}") { visit_housing_unit action }
  end

  private

  def assert_link_to_housing_facility
    within '#housing-facility_sidebar_section' do
      assert_selector "a[href='/housing_facilities/#{@housing_facility.id}']",
                    text: @housing_facility.name
    end
  end
end