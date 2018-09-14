require 'test_helper'

class Stay::SumAttendeeCostTest < ServiceTestCase
  setup do
    @attendee = create :attendee
    @cost_code = create_cost_code max_days: 100,
                                  adult_cents: 111,
                                  single_delta_cents: 666
    @dormitory = create :housing_facility, housing_type: :dormitory,
                                           cost_code: @cost_code
    @dorm_unit = create :housing_unit, housing_facility: @dormitory

    @apartment = create :housing_facility, housing_type: :apartment,
                                           cost_code: @cost_code
    @apt_unit = create :housing_unit, housing_facility: @apartment

    @arrived_at = Date.parse('2017-01-01')

    @service = Stay::SumAttendeeCost.new(attendee: @attendee)
  end

  test 'no stays' do
    @service.call
    refute @service.charges.key?('dorm_adult'),
      'there should be no "dorm_adult" stays'
    refute @service.charges.key?('apartment_rent'),
      'there should be no "apartment_rent" stays'
  end

  test '1 dorm' do
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @service.call
    assert_equal Money.new(111 * 5), @service.charges['dorm_adult']
  end

  test '2 dorms' do
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @arrived_at += 10.days
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 3.days)

    @service.call
    assert_equal Money.new(111 * (5 + 3)), @service.charges['dorm_adult']
  end

  test '1 apartment' do
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @service.call
    assert_equal Money.new(111 * 5), @service.charges['apartment_rent']
  end

  test '2 apartments' do
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @arrived_at += 10.days
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 3.days)

    @service.call
    assert_equal Money.new(111 * (5 + 3)), @service.charges['apartment_rent']
  end

  test '1 dorm, single-occupancy' do
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days),
                            single_occupancy: true

    @service.call
    assert_equal Money.new((111 + 666) * 5), @service.charges['dorm_adult']
  end

  test '1 apartment, no charge' do
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 8.days), no_charge: true

    @service.call
    assert_equal Money.empty, @service.charges['apartment_rent']
  end

  test '1 apartment, only has to pay a percentage' do
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 8.days),
                            percentage: 25

    @service.call
    assert_equal Money.new(111 * 8 / 4.0), @service.charges['apartment_rent']
  end

  test '1 dorm and 1 apartment' do
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 4.days)

    @service.call
    assert_equal Money.new(111 * 5), @service.charges['dorm_adult']
    assert_equal Money.new(111 * 4), @service.charges['apartment_rent']
  end

  test '2 dorms and 2 apartments' do
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 2.days)
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 3.days)
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 4.days)
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @service.call
    assert_equal Money.new(111 * (2 + 3)), @service.charges['dorm_adult']
    assert_equal Money.new(111 * (4 + 5)), @service.charges['apartment_rent']
  end

  test '2 dorms, but 1 is single-occupancy' do
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @arrived_at += 10.days
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 3.days),
                            single_occupancy: true

    @service.call
    assert_equal Money.new(111 * 5 + (111 + 666) * 3), @service.charges['dorm_adult']
  end

  test '2 apartments, but 1 only needs partial payment' do
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @arrived_at += 10.days
    @attendee.stays.create! housing_unit: @apt_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 3.days),
                            percentage: 25

    @service.call
    assert_equal Money.new(111 * 5 + 111 * 3 / 4.0), @service.charges['apartment_rent']
  end

  test '2 dorms that cross the charge boundary' do
    create :cost_code_charge, cost_code: @cost_code, max_days: 200,
                              adult_cents: 1_00
    @cost_code.reload

    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 100.days)
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 1.day)

    @service.call

    assert_equal Money.new(1_00 * 101), @service.charges['dorm_adult']
  end

  test 'no charge type' do
    @attendee.stays.create! housing_unit: @dorm_unit, arrived_at: @arrived_at,
                            departed_at: (@arrived_at + 5.days)

    @dormitory.stub :housing_type, 'unknown' do
      assert_raise Stay::SingleAttendeeCost::NoCostTypeError do
        @service.call
      end
    end
  end

  private

  def create_cost_code(charge_args)
    create(:cost_code, min_days: 1).tap do |code|
      create :cost_code_charge, charge_args.reverse_merge(cost_code: code)
    end
  end
end
