require 'test_helper'

class Course::SumAttendeeCostTest < ServiceTestCase
  setup do
    @attendee = create :attendee, seminary: create(:seminary,
                                                   course_price_cents: 100_00)
    @service = Course::SumAttendeeCost.new(attendee: @attendee)
  end

  test '1 course' do
    create_course(price_cents: 123_00)

    @service.call

    assert_equal Money.new(123_00), @service.charges[:tuition_class]
  end

  test '2 courses' do
    create_course(price_cents: 123_00)
    create_course(price_cents: 234_00)

    @service.call

    assert_equal Money.new(357_00), @service.charges[:tuition_class]
  end

  test '1 course with credit' do
    create_seminary_course(price_cents: 123_00)

    @service.call

    assert_equal Money.new(123_00), @service.charges[:tuition_class]
    assert_equal Money.new(100_00), @service.seminary_price
  end

  test '2 courses with credit' do
    create_seminary_course(price_cents: 123_00)
    create_seminary_course(price_cents: 234_00)

    @service.call

    assert_equal Money.new(357_00), @service.charges[:tuition_class]
    assert_equal Money.new(200_00), @service.seminary_price
  end

  private

  def create_seminary_course(args = {})
    create_course(args.merge(seminary_credit: true))
  end

  def create_course(args = {})
    @attendee.course_attendances << CourseAttendance.create(
      seminary_credit: args.delete(:seminary_credit),
      course: create(:course, args)
    )
  end
end
