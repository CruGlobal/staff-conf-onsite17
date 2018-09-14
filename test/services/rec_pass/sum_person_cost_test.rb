require 'test_helper'

class RecPass::SumPersonRecPassCostTest < ServiceTestCase
  setup do
    @person = create :attendee
    @dorm_unit = create :dormitory_unit
    @date = Date.parse('2017-01-01')

    @service = RecPass::SumPersonCost.new(person: @person)
  end

  stub_user_variable rec_center_daily: Money.new(123_45)

  test 'not applicable' do
    update_dates(nil, nil)

    @service.call

    assert_equal Money.empty, @service.charges[:rec_center]
  end

  test '1 day' do
    update_dates(@date, @date)

    @service.call

    assert_equal Money.new(123_45 * 1), @service.charges[:rec_center]
  end

  test '2 days' do
    update_dates(@date, @date + 1.day)

    @service.call

    assert_equal Money.new(123_45 * 2), @service.charges[:rec_center]
  end

  test '1 day, in a dorm' do
    update_dates(@date, @date)
    create :stay, housing_unit: @dorm_unit, person: @person, arrived_at: @date,
                  departed_at: @date
    @person.reload

    @service.call

    assert_equal Money.empty, @service.charges[:rec_center]
  end

  test '2 days, 1 in a dorm' do
    update_dates(@date, @date + 1.day)
    create :stay, housing_unit: @dorm_unit, person: @person, arrived_at: @date,
                  departed_at: @date
    @person.reload

    @service.call

    assert_equal Money.new(123_45 * 1), @service.charges[:rec_center]
  end

  private

  def update_dates(start, finish)
    @person.update!(rec_pass_start_at: start, rec_pass_end_at: finish)
  end
end
