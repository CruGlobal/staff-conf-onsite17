require 'test_helper'

class Childcare::SumChildCostTest < ServiceTestCase
  setup do
    @child = create :child, grade_level: :grade1, childcare_deposit: false
    @service = Childcare::SumChildCost.new(child: @child)
  end

  stub_user_variable childcare_week_0:  Money.new(1_00),
                     childcare_week_1:  Money.new(2_00),
                     childcare_week_2:  Money.new(4_00),
                     childcare_week_3:  Money.new(8_00),
                     childcare_week_4:  Money.new(16_00),
                     childcare_deposit: Money.new(32_00)

  test '0 weeks' do
    @child.update!(childcare_weeks: [])
    @service.call
    assert_equal Money.empty, @service.charges[:childcare]
  end

  test '0 weeks + deposit' do
    @child.update!(childcare_weeks: [], childcare_deposit: true)
    @service.call
    assert_equal Money.new(32_00), @service.charges[:childcare]
  end

  test '1 week' do
    @child.update!(childcare_weeks: [3])
    @service.call
    assert_equal Money.new(8_00), @service.charges[:childcare]
  end

  test '2 weeks' do
    @child.update!(childcare_weeks: [1, 2])
    @service.call
    assert_equal Money.new(6_00), @service.charges[:childcare]
  end

  test '2 weeks + deposit' do
    @child.update!(childcare_weeks: [1, 2], childcare_deposit: true)
    @service.call
    assert_equal Money.new(38_00), @service.charges[:childcare]
  end
end
