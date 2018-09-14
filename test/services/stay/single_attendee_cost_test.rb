require 'test_helper'

class Stay::SingleAttendeeCostTest < ServiceTestCase
  setup do
    @attendee = create :attendee
    @cost_code = create_cost_code max_days: 100,
                                  adult_cents: 111,
                                  single_delta_cents: 666
    @arrived_at = Date.parse('2017-01-01')
  end

  test 'self-provided housing' do
    @stay = create_stay(nil, 5.days)
    @service = Stay::SingleAttendeeCost.new(stay: @stay)

    @service.call

    assert_equal Money.empty, @service.total
  end

  test 'dormitory' do
    @stay = create_stay(:dormitory, 5.days)
    @service = Stay::SingleAttendeeCost.new(stay: @stay)

    @service.call

    assert_equal Money.new(5_55), @service.total
  end

  test 'dormitory, single-occupancy' do
    @stay = create_stay(:dormitory, 10.days, single_occupancy: true)
    @service = Stay::SingleAttendeeCost.new(stay: @stay)

    @service.call

    assert_equal Money.new(11_10 + 66_60), @service.total
  end

  test 'apartment' do
    @stay = create_stay(:apartment, 3.days)
    @service = Stay::SingleAttendeeCost.new(stay: @stay)

    @service.call

    assert_equal Money.new(3_33), @service.total
  end

  test 'apartment, must pay half' do
    @stay = create_stay(:apartment, 10.days, percentage: 50)
    @service = Stay::SingleAttendeeCost.new(stay: @stay)

    @service.call

    assert_equal Money.new(5_55), @service.total
  end

  private

  def create_cost_code(charge_args)
    create(:cost_code, min_days: 1).tap do |code|
      create :cost_code_charge, charge_args.reverse_merge(cost_code: code)
    end
  end

  def create_stay(housing_type, duration, args = {})
    unit =
      if housing_type.present?
        facility = create :housing_facility, housing_type: housing_type,
                                             cost_code: @cost_code
        create :housing_unit, housing_facility: facility
      end

    @attendee.stays.create!(
      args.reverse_merge(housing_unit: unit, arrived_at: @arrived_at,
                         departed_at: (@arrived_at + duration))
    )
  end
end
