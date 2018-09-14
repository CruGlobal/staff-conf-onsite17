require 'test_helper'

class Course::ShowTest < IntegrationTest
  before do
    @user = create_login_user
    @course = create :course
  end

  test '#show details' do
    visit course_path(@course)

    assert_selector '#page_title', text: @course.name
    assert_show_rows :name, :instructor, :price, :description, :ibs_code,
                     :location, :created_at, :updated_at
    assert_active_admin_comments
  end

  test '#show attendees when empty' do
    visit course_path(@course)

    within('.attendees.panel') { assert_text 'None' }
  end

  test '#show attendees' do
    @attendee = create :attendee, courses: [@course]

    visit course_path(@course)

    within('.attendees.panel') { assert_text @attendee.full_name }
  end
end
