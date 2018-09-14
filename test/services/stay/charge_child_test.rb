require 'test_helper'

class Stay::ChargeChildCostTest < ServiceTestCase
  setup do

    @child = create :child
    @cost_code = create_cost_code max_days: 100,
                                  adult_cents: 111,
                                  teen_cents: 222,
                                  child_cents: 333,
                                  infant_cents: 444,
                                  child_meal_cents: 555,
                                  single_delta_cents: 666
    @dormitory = create :housing_facility, housing_type: :dormitory,
                                           cost_code: @cost_code
    @unit = create :housing_unit, housing_facility: @dormitory

    @arrived_at = Date.parse('2017-01-01')
    @child.stays.create! housing_unit: @unit, arrived_at: @arrived_at,
                         departed_at: (@arrived_at + 5.days)

    @service = Stay::ChargeChildCost.new(child: @child)
  end

  stub_user_variable child_age_cutoff: 6.months.from_now


  test 'adult with price cost adjustment' do
    @child.update!(birthdate: 15.years.ago)

    create :cost_adjustment, price_cents: 200, person: @child, cost_type: :dorm_child
    @service.call
    assert_equal Money.new(111 * 5 - 200), @service.total
  end

  test 'adult with percent cost adjustment' do
    @child.update!(birthdate: 15.years.ago)

    create :cost_adjustment, percent: 50, person: @child, cost_type: :dorm_child
    @service.call
    assert_equal Money.new(111 * 5 / 2), @service.total
  end

  test 'infant with many cost adjustments' do
    @child.update!(birthdate: 2.years.ago)

    create :cost_adjustment, price_cents: 12_00, person: @child, cost_type: :dorm_child
    create :cost_adjustment, price_cents: 3_45, person: @child, cost_type: :dorm_child

    create :cost_adjustment, percent: 10, person: @child, cost_type: :dorm_child
    create :cost_adjustment, percent:  3, person: @child, cost_type: :dorm_child

    @service.call
    assert_equal Money.new(444 * 5 * 0.87 - 15_45), @service.total
  end

  test 'a cost adjustment that is more than the cost due' do
    @child.update!(birthdate: 2.years.ago)

    create :cost_adjustment, price_cents: 5_000_00, person: @child, cost_type: :dorm_child

    @service.call
    assert_equal Money.empty, @service.total
  end

  private

  def create_cost_code(charge_args)
    create(:cost_code, min_days: 1).tap do |code|
      create :cost_code_charge, charge_args.reverse_merge(cost_code: code)
    end
  end
end
