require 'test_helper'

class JuniorSenior::SumChildCostTest < ServiceTestCase
  setup do
    @child = create :child, grade_level: :grade9, childcare_deposit: false
    @service = JuniorSenior::SumChildCost.new(child: @child)
  end

  stub_user_variable junior_senior_week_0: Money.new(32_00),
                     junior_senior_week_1: Money.new(64_00),
                     junior_senior_week_2: Money.new(128_00),
                     junior_senior_week_3: Money.new(256_00),
                     junior_senior_week_4: Money.new(512_00),
                     childcare_deposit: Money.new(32_00)

  test 'junior/senior 0 weeks' do
    @child.update!(childcare_weeks: [])
    @service.call
    assert_equal Money.empty, @service.charges[:junior_senior]
  end

  test 'junior/senior 1 week' do
    @child.update!(childcare_weeks: [3])
    @service.call
    assert_equal Money.new(256_00), @service.charges[:junior_senior]
  end

  test 'junior/senior 2 weeks' do
    @child.update!(childcare_weeks: [1, 2])
    @service.call
    assert_equal Money.new(192_00), @service.charges[:junior_senior]
  end

  test 'junior/senior 2 weeks + deposit' do
    @child.update!(childcare_weeks: [1, 2], childcare_deposit: true)
    @service.call
    assert_equal Money.new(224_00), @service.charges[:junior_senior]
  end
end
