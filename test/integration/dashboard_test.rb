require 'test_helper'

class DashboardTest < IntegrationTest
  before do
    @user = create_login_user
  end

  test 'Login Page' do
    visit dashboard_path
    assert_title 'Dashboard'
  end

  test 'Recently Updated' do
    course = create :course
    course.update name: 'Something'
    course.update name: 'Something Else'

    visit dashboard_path

    assert_equal 3, course.versions.size
    course.versions.each do |v|
      assert_selector "#paper_trail_version_#{v.id}", text: course.audit_name
    end
  end
end

