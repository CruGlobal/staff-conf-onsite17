require 'test_helper'

class Attendee::FormTest < IntegrationTest
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

  test '#edit fields' do
    visit edit_attendee_path(@attendee)

    assert_edit_fields :student_number, :first_name, :last_name, :gender,
                       :birthdate, :arrived_at, :departed_at, :email, :phone,
                       :emergency_contact, :ministry_id, :department,
                       :rec_pass_start_at, :rec_pass_end_at,
                       record: @attendee

    assert_active_admin_comments
  end

  test '#edit add cost_adjustment' do
    enable_javascript!
    login_user @user
    @attendee.cost_adjustments.each(&:destroy!)

    attrs = attributes_for :cost_adjustment

    visit edit_attendee_path(@attendee)

    assert_difference "CostAdjustment.where(person_id: #{@attendee.id}).count" do
      within('.cost_adjustments.panel') do
        click_link 'Add New Cost adjustment'

        select_option('Cost type')
        fill_in 'Price', with: attrs[:price_cents]
        fill_in 'Percent', with: attrs[:percent]
        fill_in 'Description', with: attrs[:description]
      end

      click_button 'Update Attendee'
      assert_current_path attendee_path(@attendee)
    end
  end

  test '#edit admin can change family_id' do
    @admin = create :admin_user
    login_user @admin

    visit edit_attendee_path(@attendee)

    within('.basic.inputs') do
      assert_selector '[name="attendee[family_id]"]'
    end
  end

  test '#edit finance user cannot change family_id' do
    @finance = create :finance_user
    login_user @finance

    visit edit_attendee_path(@attendee)

    within('.basic.inputs') do
      refute_selector 'select[name="attendee[family_id]"]'
    end
  end

  test '#edit general user cannot change family_id' do
    @general = create :general_user
    login_user @general

    visit edit_attendee_path(@attendee)

    within('.basic.inputs') do
      refute_selector 'select[name="attendee[family_id]"]'
    end
  end

  test '#new record creation' do
    @family = create :family
    attr = attributes_for :attendee

    visit edit_family_path(@family)
    click_link 'New Attendee'

    assert_difference 'Attendee.count' do
      within('form#new_attendee') do
        fill_in 'Student number', with: attr[:student_number]
        fill_in 'First name',     with: attr[:first_name]
        fill_in 'Last name',      with: attr[:last_name]
        select 'Male', from: 'Gender'

        fill_in 'Start', with: attr[:rec_pass_start_at]
        fill_in 'End',   with: attr[:rec_pass_end_at]
      end

      click_button 'Create Attendee'
    end
  end
end
