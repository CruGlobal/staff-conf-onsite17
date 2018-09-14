require 'test_helper'

class StayTest < ModelTestCase
  setup do
    @cost_code = create :cost_code
    @charge = create :cost_code_charge, cost_code: @cost_code, max_days: 99999
    @facility = create :housing_facility, cost_code: @cost_code
    @unit = create :housing_unit, housing_facility: @facility
    @attendee = create :attendee

    @stay = create :stay, person: @attendee, housing_unit: @unit,
                          waive_minimum: true
  end

  test '#housing_type' do
    assert_equal @facility.housing_type, @stay.housing_type
  end

  test '#housing_type is self_provided when Unit is absent' do
    @stay.housing_unit = nil
    assert_equal 'self_provided', @stay.housing_type
  end

  test '#housing_type is self_provided when Unit\'s Facility is absent' do
    @unit.housing_facility = nil
    assert_equal 'self_provided', @stay.housing_type
  end

  test '#duration' do
    @stay.update!(arrived_at: 6.days.ago, departed_at: 3.days.ago)

    assert_equal 3, @stay.duration
    @stay.departed_at = 6.days.ago + 1.hour
    assert_equal 1, @stay.duration
  end

  test '#total_duration for apartment' do
    @stay.update!(housing_unit: create(:apartment_unit),
                  arrived_at: 6.days.ago, departed_at: 3.days.ago)

    assert_equal 3, @stay.total_duration
    @stay.departed_at = 6.days.ago + 1.hour
    assert_equal 1, @stay.duration
  end

  test '#total_duration for dorms in different facilities' do
    @cost_code.update!(min_days: 1)
    @stay.update!(housing_unit: create(:dormitory_unit),
                  arrived_at: 6.days.ago, departed_at: 3.days.ago)

    @another_stay = create :stay, person: @attendee,
                                  housing_unit: create(:dormitory_unit),
                                  arrived_at: 4.days.ago,
                                  departed_at: 2.days.ago

    assert_equal 5, @stay.total_duration
  end

  test '#min_days' do
    @stay.update!(waive_minimum: false)
    @facility.update!(cost_code: create(:cost_code, min_days: 123))

    assert_equal 123, @stay.min_days
  end

  test 'stay duration longer than cost_code#max_days' do
    @charge.update!(max_days: 10)

    assert_raise ActiveRecord::RecordInvalid do
      @stay.update!(arrived_at: 1.day.ago, departed_at: 10.days.from_now)
    end
  end

  test 'sum of 2 stay durations longer than cost_code#max_days' do
    @charge.update!(max_days: 10)

    @stay.update!(arrived_at: 1.day.ago, departed_at: 4.days.from_now)

    assert_raise ActiveRecord::RecordInvalid do
      create :stay, person: @attendee, housing_unit: @unit,
                    arrived_at: 1.day.ago, departed_at: 5.days.from_now
    end
  end

  test '#on_campus for a dorm' do
    @facility = create :dormitory, cost_code: @cost_code
    @unit = create :housing_unit, housing_facility: @facility
    @stay = create :stay, person: @attendee, housing_unit: @unit

    assert @stay.on_campus, 'should be on_campus'
  end

  test '#on_campus for an apartment' do
    @facility = create :apartment, cost_code: @cost_code
    @unit = create :housing_unit, housing_facility: @facility
    @stay = create :stay, person: @attendee, housing_unit: @unit

    refute @stay.on_campus, 'should NOT be on_campus'
  end

  test '#on_campus for self-provided' do
    @stay = create :stay, person: @attendee, housing_unit: nil

    refute @stay.on_campus, 'should NOT be on_campus'
  end
end
