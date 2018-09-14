require 'test_helper'

class HousingUnitTest < ModelTestCase
  setup do
    create_users
    @housing_unit = create :housing_unit
  end

  test 'permit create' do
    assert_accessible :create, @housing_unit, only: [:admin, :general]
  end

  test 'permit read' do
    assert_accessible :show, @housing_unit,
      only: [:general, :finance, :admin, :read_only]
  end

  test 'permit update' do
    assert_accessible :update, @housing_unit, only: [:admin, :general]
  end

  test 'permit destroy' do
    assert_accessible :destroy, @housing_unit, only: [:admin, :general]
  end

  test '.hierarchy when no Facilities exist' do
    HousingFacility.all.each(&:destroy!)
    hierarchy = HousingUnit.hierarchy
    assert_empty hierarchy
  end

  test '.hierarchy when one Facilities exists' do
    expected_facility = @housing_unit.housing_facility

    hierarchy = HousingUnit.hierarchy

    assert_equal 1, hierarchy.size
    assert_equal expected_facility.housing_type, hierarchy.keys.first.downcase
    assert_includes hierarchy.first.last[expected_facility], @housing_unit
  end

  test '.hierarchy when two Units share a Facility' do
    expected_facility = @housing_unit.housing_facility
    @other_unit = create :housing_unit, housing_facility: expected_facility

    hierarchy = HousingUnit.hierarchy

    assert_equal 1, hierarchy.size
    assert_equal 2, hierarchy.first.last[expected_facility].size
  end
end
