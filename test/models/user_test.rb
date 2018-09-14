require 'test_helper'

class UserTest < ModelTestCase
  setup do
    create_users
    @user = create :user
  end

  test 'general predicate' do
    assert @general_user.general?

    refute @finance_user.general?
    refute @admin_user.general?
  end

  test 'finance predicate' do
    assert @finance_user.finance?

    refute @general_user.finance?
    refute @admin_user.finance?
  end

  test 'admin predicate' do
    assert @admin_user.admin?

    refute @general_user.admin?
    refute @finance_user.admin?
  end

  test 'permit create' do
    refute_permit @general_user, @user, :create
    refute_permit @finance_user, @user, :create

    assert_permit @admin_user, @user, :create
  end

  test 'permit read' do
    assert_permit @general_user, @user, :show
    assert_permit @finance_user, @user, :show
    assert_permit @admin_user, @user, :show
  end

  test 'permit update' do
    refute_permit @general_user, @user, :update
    refute_permit @finance_user, @user, :update

    assert_permit @admin_user, @user, :update
  end

  test 'permit destroy' do
    refute_permit @general_user, @user, :destroy
    refute_permit @finance_user, @user, :destroy

    assert_permit @admin_user, @user, :destroy
  end
end
