require 'test_helper'

class ChargeableStaffNumber::IndexTest < IntegrationTest
  before do
    @user = create_login_user
    @chargeable = create :chargeable_staff_number
  end

  test '#index filters' do
    visit chargeable_staff_numbers_path

    within('.filter_form') do
      assert_text 'Staff ID'
      assert_text 'Created at'
    end
  end

  test '#index columns' do
    visit chargeable_staff_numbers_path

    assert_index_columns :selectable, :staff_number, :created_at, :actions
  end

  test '#index items' do
    visit chargeable_staff_numbers_path

    within('#index_table_chargeable_staff_numbers') do
      assert_selector "#chargeable_staff_number_#{@chargeable.id}"
    end
  end
end
