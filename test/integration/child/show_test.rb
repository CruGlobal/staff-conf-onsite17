require 'test_helper'

class Child::ShowTest < IntegrationTest
  include CostAdjustmentHelper

  before do
    @user = create_login_user
    @child = create :child, birthdate: 5.years.ago
  end

  stub_user_variable child_age_cutoff: 6.months.from_now,
                     rec_center_daily: Money.new(1_00)

  test '#show details' do
    visit child_path(@child)

    assert_selector '#page_title', text: @child.full_name

    within('.panel', text: 'Child Details') do
      assert_show_rows :first_name, :last_name, :family, :gender, :birthdate,
                       :age, :grade_level, :parent_pickup, :needs_bed,
                       :created_at, :updated_at, :rec_pass_start_at,
                       :rec_pass_end_at,
                       selector: "#attributes_table_child_#{@child.id}"
    end

    within('.panel.duration') { assert_show_rows :arrived_at, :departed_at }
    within('.panel.childcare') { assert_show_rows :childcare, :childcare_weeks }

    assert_active_admin_comments
  end

  test '#show cost_adjustments when empty' do
    visit child_path(@child)
    within('.cost_adjustments.panel') { assert_text 'None' }
  end

  test '#show cost_adjustments' do
    @cost_adjustment = create :cost_adjustment, person: @child
    visit child_path(@child)
    cost_type = cost_type_name(@cost_adjustment.cost_type)
    within('.cost_adjustments.panel') { assert_text cost_type }
  end

  test '#show housing_assignments when empty' do
    visit child_path(@child)
    within('.stays.panel') { assert_text 'None' }
  end

  test '#show housing_assignments' do
    @housing_assignment = create :stay, person: @child
    visit child_path(@child)
    within('.stays.panel') { assert_text @housing_assignment.housing_unit.name }
  end

  test '#show meal_exemptions when empty' do
    visit child_path(@child)
    within('.meal_exemptions.panel') { assert_text 'None' }
  end

  test '#show meal_exemptions' do
    @meal_exemption = create :meal_exemption, person: @child
    visit child_path(@child)
    within('.meal_exemptions.panel') { assert_text @meal_exemption.date.strftime("%B %-d") }
  end
end
