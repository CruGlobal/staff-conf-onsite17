require 'test_helper'

class Conference::ShowTest < IntegrationTest
  before do
    @user = create_login_user
    @conference = create :conference
  end

  test '#show details' do
    visit conference_path(@conference)

    assert_selector '#page_title', text: @conference.name
    assert_show_rows :name, :price, :description, :start_at, :end_at,
                     :waive_off_campus_facility_fee, :created_at, :updated_at
    assert_active_admin_comments
  end

  test '#show attendees when empty' do
    visit conference_path(@conference)

    within('.attendees.panel') { assert_text 'None' }
  end

  test '#show attendees' do
    @attendee = create :attendee, conferences: [@conference]

    visit conference_path(@conference)

    within('.attendees.panel') { assert_text @attendee.full_name }
  end
end
