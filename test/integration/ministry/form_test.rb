require 'test_helper'

class Ministry::FormTest < IntegrationTest
  before do
    @user = create_login_user
    @ministry = create :ministry
  end

  test '#edit fields' do
    visit edit_ministry_path(@ministry)

    assert_edit_fields :code, :name, :parent_id, record: @ministry

    assert_active_admin_comments
  end

  test '#new record creation' do
    attr = attributes_for :ministry

    visit new_ministry_path

    assert_difference 'Ministry.count' do
      within('form#new_ministry') do
        fill_in 'Code', with: attr[:code]
        fill_in 'Name', with: attr[:name]
      end

      click_button 'Create Ministry'
    end
  end

  test '#new record creation with a parent' do
    @parent = create :ministry, parent_id: nil
    attr = attributes_for :ministry

    visit new_ministry_path

    assert_difference 'Ministry.count' do
      within('form#new_ministry') do
        fill_in 'Code', with: attr[:code]
        fill_in 'Name', with: attr[:name]
        select @parent.name, from: 'Parent'
      end

      click_button 'Create Ministry'
    end

    @new_record = Ministry.last
    assert_equal @parent.id, @new_record.parent_id
    assert_equal attr[:code], @new_record.code
  end
end
