require 'test_helper'

class Conference::SumFamilyCostTest < ServiceTestCase
  setup do
    @staff_conference = create :conference, staff_conference: true,
                                            price_cents: 50_00

    @attendee_1 = create :attendee
    @attendee_2 = create :attendee
    @family = create :family, attendees: [@attendee_1, @attendee_2]

    @service = Conference::SumFamilyCost.new(family: @family)
  end

  test 'staff conference' do
    @attendee_1.conferences << @staff_conference
    @attendee_2.conferences << @staff_conference

    @service.call

    assert_equal Money.empty, @service.total
  end

  test 'non-staff conference' do
    @attendee_1.conferences << create(:conference, price_cents: 123_00)
    @attendee_2.conferences << create(:conference, price_cents: 234_00)

    @service.call

    assert_equal Money.new(357_00), @service.total
  end

  test 'staff conference and non-staff conference' do
    @attendee_1.conferences << @staff_conference
    @attendee_2.conferences << create(:conference, price_cents: 234_00)

    @service.call

    assert_equal Money.new(234_00), @service.total
  end

  test 'staff conference and non-staff conference (multiple)' do
    @attendee_1.conferences << @staff_conference
    @attendee_1.conferences << create(:conference, price_cents: 234_00)
    @attendee_2.conferences << @staff_conference
    @attendee_2.conferences << create(:conference, price_cents: 345_00)

    @service.call

    assert_equal Money.new(579_00), @service.total
  end
end
