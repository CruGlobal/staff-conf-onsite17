require 'test_helper'

class Ministry::ShowTest < IntegrationTest
  before do
    @user = create_login_user
    @ministry = create :ministry
  end

  test '#show details' do
    visit ministry_path(@ministry)

    assert_selector '#page_title', text: @ministry.name
    assert_show_rows :code, :name, :parent, :created_at, :updated_at
    assert_active_admin_comments
  end

  test '#show hierarchy with no parent' do
    visit ministry_path(@ministry)
    assert_no_selector '.hierarchy.panel'
  end

  test '#show hierarchy' do
    @parent = create :ministry, parent_id: nil
    @ministry.update! parent_id: @parent.id

    visit ministry_path(@ministry.id)

    within('.hierarchy.panel') { assert_text @parent.name }
  end

  test '#show members when empty' do
    visit ministry_path(@ministry)

    within('.members.panel') { assert_text 'None' }
  end

  test '#show members' do
    @member = create :attendee, ministry: @ministry

    visit ministry_path(@ministry)

    within('.members.panel') { assert_text @member.full_name }
  end
end
