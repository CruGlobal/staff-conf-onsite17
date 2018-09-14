require 'test_helper'

class ChargeableStaffNumberTest < ModelTestCase
  setup do
    create_users
    @chargeable = create :chargeable_staff_number, staff_number: '12345'
  end

  test '#family' do
    family = create :family, staff_number: '12345'

    assert_equal family, @chargeable.family
  end

  test '#family with no match' do
    Family.where(staff_number: '12345').destroy_all

    assert_nil @chargeable.family
  end
end
