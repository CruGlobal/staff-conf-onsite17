require 'test_helper'

class CostCodeTest < ModelTestCase
  setup do
    create_users
    @cost_code = create :cost_code
    @charge_10 = create :cost_code_charge, cost_code: @cost_code, max_days: 10
    @charge_20 = create :cost_code_charge, cost_code: @cost_code, max_days: 20
    @charge_30 = create :cost_code_charge, cost_code: @cost_code, max_days: 30
    @cost_code.reload
  end

  test '#charge' do
    assert_equal @charge_10, @cost_code.charge(days: 1)
    assert_equal @charge_10, @cost_code.charge(days: 10)

    assert_equal @charge_20, @cost_code.charge(days: 11)
    assert_equal @charge_20, @cost_code.charge(days: 20)

    assert_equal @charge_30, @cost_code.charge(days: 21)
    assert_equal @charge_30, @cost_code.charge(days: 30)

    assert_nil @cost_code.charge(days: 31)
  end

  test '#last_charge' do
    assert_equal @charge_30, @cost_code.last_charge

    @cost_code.charges.destroy_all
    assert_nil @cost_code.last_charge
  end

  test '#max_days' do
    assert_equal 30, @cost_code.max_days

    @cost_code.charges.destroy_all
    assert_equal 0, @cost_code.max_days
  end

  test 'permit create' do
    assert_accessible :create, @cost_code, only: [:admin, :finance]
  end

  test 'permit read' do
    assert_accessible :show, @cost_code,
      only: [:admin, :finance, :general, :read_only]
  end

  test 'permit update' do
    assert_accessible :update, @cost_code, only: [:admin, :finance]
  end

  test 'permit destroy' do
    assert_accessible :destroy, @cost_code, only: [:admin, :finance]
  end
end
