require 'test_helper'

class BulkEditTest < IntegrationTest
  before do
    create :family
  end

  test 'Select-all toggle is available for admin user' do
    create_login_user :admin

    visit families_path
    assert_selector '.resource_selection_toggle_cell'
  end

  test 'Select-all toggle is available for finance user' do
    create_login_user :finance

    visit families_path
    refute_selector '.resource_selection_toggle_cell'
  end

  test 'Select-all toggle is not available for general user' do
    create_login_user :general

    visit families_path
    refute_selector '.resource_selection_toggle_cell'
  end
end

