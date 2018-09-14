require 'test_helper'

class CostAdjustmentTest < ModelTestCase
  setup do
    create_users
    @cost_adjustment = create :cost_adjustment
  end

  test_money_attr(:cost_adjustment, :price)

  test 'percentage too low' do
    assert_raises ActiveRecord::RecordInvalid do
      create :cost_adjustment, percent: -0.1
    end
  end

  test 'percentage too high' do
    assert_raises ActiveRecord::RecordInvalid do
      create :cost_adjustment, percent: 100.1
    end
  end

  test 'price and percent mutual exclusivity' do
    assert_raises ActiveRecord::RecordInvalid do
      create :cost_adjustment, price_cents: 123, percent: 50.5
    end
  end

  test 'permit create' do
    assert_accessible :create, @cost_adjustment, only: [:admin, :finance]
  end

  test 'permit read' do
    assert_accessible :show, @cost_adjustment,
      only: [:admin, :finance, :general, :read_only]
  end

  test 'permit update' do
    assert_accessible :update, @cost_adjustment, only: [:admin, :finance]
  end

  test 'permit destroy' do
    assert_accessible :destroy, @cost_adjustment, only: [:admin, :finance]
  end
end
