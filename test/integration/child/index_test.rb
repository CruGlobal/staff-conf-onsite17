require 'test_helper'

class Child::IndexTest < IntegrationTest
  before do
    @user = create_login_user
    @child = create :child, :childcare
    @childcare = create :childcare
  end

  stub_user_variable child_age_cutoff: 6.months.from_now

  test '#index filters' do
    visit children_path

    within('.filter_form') do
      assert_text 'First name'
      assert_text 'Last name'
      assert_text 'Birthdate'
      assert_text 'Gender'
      assert_text 'PM Car Line'
      assert_text 'Needs bed'
      assert_text 'Requested Arrival'
      assert_text 'Requested Departure'
    end
  end

  test '#index set childcare' do
    enable_javascript!
    login_user(@user)

    @child.update!(childcare_id: nil)

    visit children_path
    within("#child_#{@child.id}") do
      select_option('child[childcare_id]')
    end
    wait_for_ajax!

    refute_nil @child.reload.childcare_id
  end

  test '#index set childcare invalid' do
    enable_javascript!
    login_user(@user)

    @old_child = create :child, :senior

    visit children_path
    within("#child_#{@old_child.id}") do
      refute_selector "select[name='child[childcare_id]']"
    end
  end

  test '#index columns' do
    visit children_path

    assert_index_columns :selectable, :first_name, :last_name, :family, :gender,
                         :birthdate, :age, :grade_level, :actions
  end

  test '#index items' do
    visit children_path

    within('#index_table_children') do
      assert_selector "#child_#{@child.id}"
    end
  end

end
