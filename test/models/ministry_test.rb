require 'test_helper'

class MinistryTest < ModelTestCase
  setup do
    create_users
    @ministry = create :ministry
  end

  test 'own parent' do
    @ministry.parent = @ministry
    refute @ministry.valid?, 'cannot be your own parent'
  end

  test 'ancestors' do
    child = create :ministry, parent: @ministry
    gchild = create :ministry, parent: child
    ggchild = create :ministry, parent: gchild
    gggchild = create :ministry, parent: ggchild

    assert_equal [@ministry, child, gchild, ggchild], gggchild.ancestors
  end

  test 'no ancestors' do
    assert_empty @ministry.ancestors
  end

  test 'permit create' do
    refute_permit @general_user, @ministry, :create
    refute_permit @finance_user, @ministry, :create

    assert_permit @admin_user, @ministry, :create
  end

  test 'permit read' do
    assert_permit @general_user, @ministry, :show
    assert_permit @finance_user, @ministry, :show
    assert_permit @admin_user, @ministry, :show
  end

  test 'permit update' do
    refute_permit @general_user, @ministry, :update
    refute_permit @finance_user, @ministry, :update

    assert_permit @admin_user, @ministry, :update
  end

  test 'permit destroy' do
    refute_permit @general_user, @ministry, :destroy
    refute_permit @finance_user, @ministry, :destroy

    assert_permit @admin_user, @ministry, :destroy
  end
end
