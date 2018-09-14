require 'test_helper'

class Attendee::ShowTest < IntegrationTest
  before do
    @user = create_login_user
    @attendee = create :attendee
  end

  stub_user_variable child_age_cutoff: 6.months.from_now.to_date,
                     rec_center_daily: Money.new(1_00),
                     facility_use_start: 3.months.ago.to_date,
                     facility_use_split: 2.months.ago.to_date,
                     facility_use_end: 1.month.ago.to_date,
                     facility_use_before: Money.new(1_00),
                     facility_use_after: Money.new(2_00)

  test '#show details' do
    visit attendee_path(@attendee)

    assert_selector '#page_title', text: @attendee.full_name
    assert_show_rows :first_name, :last_name, :family, :birthdate, :age,
                     :gender, :email, :phone, :emergency_contact, :ministry,
                     :department, :created_at, :updated_at, :rec_pass_start_at,
                     :rec_pass_end_at,
                     selector: "#attributes_table_attendee_#{@attendee.id}"

    within '.attendances.panel' do
      assert_text 'Student Number'
      assert_text 'IBS Comments'
    end

    assert_active_admin_comments
  end

  test '#show conferences when empty' do
    visit attendee_path(@attendee)
    within('.conferences.panel') { assert_text 'None' }
  end

  test '#show conferences' do
    @conference = create :conference, attendees: [@attendee]
    visit attendee_path(@attendee)
    within('.conferences.panel') { assert_text @conference.name }
  end

  test '#show cost_adjustments when empty' do
    visit attendee_path(@attendee)
    within('.cost_adjustments.panel') { assert_text 'None' }
  end

  test '#show cost_adjustments' do
    @cost_adjustment = create :cost_adjustment, person: @attendee, cost_type: :tuition_mpd
    visit attendee_path(@attendee)
    within('.cost_adjustments.panel') { assert_text 'MPD Tuition' }
  end

  test '#show attendances when empty' do
    visit attendee_path(@attendee)
    within('.attendances.panel') { assert_text 'None' }
  end

  test '#show attendances' do
    @course = create :course, attendees: [@attendee]
    visit attendee_path(@attendee)
    within('.attendances.panel') { assert_text @course.name }
  end

  test '#show housing_assignments' do
    @stay = create :stay, person: @attendee
    visit attendee_path(@attendee)
    within('.stays.panel') { assert_text @stay.housing_unit.name }
  end
end
