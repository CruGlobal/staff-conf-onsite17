require 'test_helper'

class HousingUnit::IndexTest < IntegrationTest
  include Support::HousingUnit

  before { prepare_for_testing }

  test '#index navigation' do
    navigate_to_housing_units

    assert_selector 'h2#page_title', text: "#{@housing_facility.name}: Units"
  end

  test '#index filters' do
    visit_housing_unit :index

    within('.filter_form') do
      assert_text 'Housing facility'
      assert_text 'Stays'
      assert_text 'People'
      assert_text 'Name'
      assert_text 'Created at'
      assert_text 'Updated at'
    end
  end

  test '#index columns' do
    visit_housing_unit :index

    assert_index_columns :name, :created_at, :updated_at, :actions
  end

  test '#index items' do
    visit_housing_unit :index

    within('#index_table_housing_units') do
      assert_selector "#housing_unit_#{@housing_facility.housing_units.sample.id}"
    end
  end
end
