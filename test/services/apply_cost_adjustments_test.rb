require 'test_helper'

class ApplyCostAdjustmentsTest < ServiceTestCase
  setup do
    @person = create :attendee
    @charges = {
      'dorm_adult' => Money.new(1_000_00) # $1,000.00
    }
  end

  test '0 adjustments' do
    @service = create_service

    @service.call

    assert_equal Money.empty, @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.new(1000_00), @service.total
  end

  test '1 price adjustment' do
    @service = create_service price_cents: 250_00

    @service.call

    assert_equal Money.new(250_00), @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.new(750_00), @service.total
  end

  test '2 price adjustments' do
    @service = create_service({price_cents: 250_00}, {price_cents: 1_00})

    @service.call

    assert_equal Money.new(251_00), @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.new(749_00), @service.total
  end

  test '1 percent adjustment' do
    @service = create_service percent: 50.0

    @service.call

    assert_equal Money.new(500_00), @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.new(500_00), @service.total
  end

  test '2 percent adjustments' do
    @service = create_service({percent: 50.0}, {percent: 25.0})

    @service.call

    assert_equal Money.new(750_00), @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.new(250_00), @service.total
  end

  test '1 price adjustment and 1 percent adjustment' do
    @service = create_service({price_cents: 150_00}, {percent: 50.0})

    @service.call

    assert_equal Money.new(650_00), @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.new(350_00), @service.total
  end

  test '1 price adjustment, should not be negative' do
    @service = create_service price_cents: 1_250_00

    @service.call

    assert_equal Money.new(1000_00), @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.empty, @service.total
  end

  test '2 percent adjustments, should not be negative' do
    @service = create_service({percent: 50.0}, {percent: 85.0})

    @service.call

    assert_equal Money.new(1000_00), @service.total_adjustments
    assert_equal Money.new(1000_00), @service.subtotal
    assert_equal Money.empty, @service.total
  end

  test 'total_adjustments not more than subtotal' do
    @charges['dorm_child'] = Money.new(1_00)

    create :cost_adjustment, person_id: @person.id, cost_type: 'dorm_adult',
                             price_cents: 600_00
    create :cost_adjustment, person_id: @person.id, cost_type: 'dorm_child',
                             price_cents: 600_00

    @service =
      ApplyCostAdjustments.call(charges: @charges,
                                cost_adjustments: @person.cost_adjustments)

    assert_equal Money.new(601_00), @service.total_adjustments
  end

  private

  def create_service(*args)
    args.each do |attrs|
      create :cost_adjustment, attrs.reverse_merge(
        person_id: @person.id,
        cost_type: 'dorm_adult'
      )
    end

    ApplyCostAdjustments.new(charges: @charges,
                             cost_adjustments: @person.cost_adjustments)
  end
end
