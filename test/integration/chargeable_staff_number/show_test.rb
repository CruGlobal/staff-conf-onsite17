require 'test_helper'

class ChargeableStaffNumber::ShowTest < IntegrationTest
  before do
    @user = create_login_user
    @chargeable = create :chargeable_staff_number
  end

  test '#show details' do
    visit chargeable_staff_number_path(@chargeable)

    assert_show_rows :staff_number, :created_at
    assert_active_admin_comments
  end

  test '#show family when empty' do
    visit chargeable_staff_number_path(@chargeable)

    within('.family.panel') { assert_text 'None' }
  end

  test '#show family' do
    @family = create :family, staff_number: @chargeable.staff_number

    visit chargeable_staff_number_path(@chargeable)

    within('.family.panel') { assert_text @family.to_s }
  end
end
