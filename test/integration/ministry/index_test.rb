require 'test_helper'

class Ministry::IndexTest < IntegrationTest
  before do
    @user = create_login_user
    @ministry = create :ministry
  end

  test '#index filters' do
    visit ministries_path

    within('.filter_form') do
      assert_text 'Code'
      assert_text 'Name'
      assert_text 'Created at'
      assert_text 'Updated at'
    end
  end

  test '#index columns' do
    visit ministries_path

    assert_index_columns :selectable, :name, :parent, :members, :created_at,
                         :updated_at, :actions
  end

  test '#index items' do
    visit ministries_path

    within('#index_table_ministries') do
      assert_selector "#ministry_#{@ministry.id}"
    end
  end
end
