require 'test_helper'

class Conference::IndexTest < IntegrationTest
  before do
    @user = create_login_user
    @conference = create :conference
  end

  test '#index filters' do
    visit conferences_path

    within('.filter_form') do
      assert_text 'Name'
      assert_text 'Description'
      assert_text 'Start at'
      assert_text 'End at'
      assert_text 'Created at'
      assert_text 'Updated at'
    end
  end

  test '#index columns' do
    visit conferences_path

    assert_index_columns :selectable, :name, :price, :description, :start_at,
                         :end_at, :attendees, :created_at, :updated_at, :actions
  end

  test '#index items' do
    visit conferences_path

    within('#index_table_conferences') do
      assert_selector "#conference_#{@conference.id}"
    end
  end
end
