require 'test_helper'

class Course::IndexTest < IntegrationTest
  before do
    @user = create_login_user
    @course = create :course
  end

  test '#index filters' do
    visit courses_path

    within('.filter_form') do
      assert_text 'Name'
      assert_text 'Instructor'
      assert_text 'Description'
      assert_text 'Week descriptor'
      assert_text 'IBS ID'
      assert_text 'Location'
      assert_text 'Created at'
      assert_text 'Updated at'
    end
  end

  test '#index columns' do
    visit courses_path

    assert_index_columns :selectable, :name, :instructor, :price, :description,
                         :week_descriptor, :ibs_code, :location, :attendees,
                         :created_at, :updated_at, :actions
  end

  test '#index items' do
    visit courses_path

    within('#index_table_courses') do
      assert_selector "#course_#{@course.id}"
    end
  end
end
