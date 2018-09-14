require 'test_helper'

class SeminaryTest < ModelTestCase
  setup  { @seminary = create :seminary_with_attendees }
  before do
    @seminary.reload
    SeedSeminaries.new.call
  end

  test_money_attr(:seminary, :course_price)

  [:name, :code, :course_price_cents].each do |attribute|
    test "invalid without #{attribute}" do
      refute @seminary.update({ attribute => nil })
      assert @seminary.errors[attribute].present?
    end
  end

  test 'code must be unique' do
    assert_raises ActiveRecord::RecordNotUnique do
      create :seminary, code: @seminary.code
    end
  end

  test 'has_many Attendees' do
    assert_equal 3, @seminary.attendees.size
  end

  test 'default seminary should be IBS' do
    assert_equal Seminary.default.code, 'IBS'
  end
end
