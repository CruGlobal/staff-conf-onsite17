require 'test_helper'

class ConferenceTest < ModelTestCase
  setup do
    create_users
    @conference = create :conference
  end

  test_money_attr(:conference, :price)

  test 'permit create' do
    refute_permit @general_user, @conference, :create

    assert_permit @finance_user, @conference, :create
    assert_permit @admin_user, @conference, :create
  end

  test 'permit read' do
    assert_permit @general_user, @conference, :show
    assert_permit @finance_user, @conference, :show
    assert_permit @admin_user, @conference, :show
  end

  test 'permit update' do
    refute_permit @general_user, @conference, :update

    assert_permit @finance_user, @conference, :update
    assert_permit @admin_user, @conference, :update
  end

  test 'permit destroy' do
    refute_permit @general_user, @conference, :destroy

    assert_permit @finance_user, @conference, :destroy
    assert_permit @admin_user, @conference, :destroy
  end
end
