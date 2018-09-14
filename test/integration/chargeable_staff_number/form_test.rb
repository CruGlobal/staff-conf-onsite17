require 'test_helper'

class ChargeableStaffNumber::FormTest < IntegrationTest
  before do
    @user = create_login_user
    @chargeable = create :chargeable_staff_number
  end

  test '#edit fields' do
    visit edit_chargeable_staff_number_path(@chargeable)

    assert_edit_fields :staff_number, record: @chargeable

    assert_active_admin_comments
  end

  test '#new record creation' do
    attr = attributes_for :chargeable_staff_number

    visit new_chargeable_staff_number_path

    assert_difference 'ChargeableStaffNumber.count' do
      within('form#new_chargeable_staff_number') do
        fill_in 'Staff ID',        with: attr[:staff_number]
      end

      click_button 'Create Chargeable Staff ID'
    end
  end
end
