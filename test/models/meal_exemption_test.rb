require 'test_helper'

class MealExemptionTest < ModelTestCase
  setup do
    create_users
    @meal_exemption = create :meal_exemption
  end

  test 'permit create' do
    assert_permit @general_user, @meal_exemption, :create
    assert_permit @finance_user, @meal_exemption, :create
    assert_permit @admin_user, @meal_exemption, :create
  end

  test 'permit read' do
    assert_permit @general_user, @meal_exemption, :show
    assert_permit @finance_user, @meal_exemption, :show
    assert_permit @admin_user, @meal_exemption, :show
  end

  test 'permit update' do
    assert_permit @general_user, @meal_exemption, :update
    assert_permit @finance_user, @meal_exemption, :update
    assert_permit @admin_user, @meal_exemption, :update
  end

  test 'permit destroy' do
    assert_permit @general_user, @meal_exemption, :destroy
    assert_permit @finance_user, @meal_exemption, :destroy
    assert_permit @admin_user, @meal_exemption, :destroy
  end

  test 'order_by_date when empty' do
    hash = MealExemption.where('1 = 0').order_by_date
    assert_empty hash
  end

  test 'order_by_date' do
    attendee = create :attendee

    breakfast, lunch, dinner = MealExemption::TYPES

    date1 = Date.parse('2016-01-01')
    date2 = Date.parse('2016-07-22')
    date3 = Date.parse('2016-09-11')
    dateUnused = Date.parse('2999-12-31')

    attendee.meal_exemptions.create(date: date1, meal_type: breakfast)
    attendee.meal_exemptions.create(date: date1, meal_type: lunch)
    attendee.meal_exemptions.create(date: date1, meal_type: dinner)

    attendee.meal_exemptions.create(date: date2, meal_type: dinner)

    attendee.meal_exemptions.create(date: date3, meal_type: breakfast)
    attendee.meal_exemptions.create(date: date3, meal_type: dinner)

    hash = attendee.meal_exemptions.order_by_date

    assert_equal 3, hash.keys.size
    assert_equal 3, hash[date1].size
    assert_equal 1, hash[date2].size
    assert_equal 2, hash[date3].size
    assert_empty hash[dateUnused]

    assert_kind_of MealExemption, hash[date1][breakfast]
    assert_kind_of MealExemption, hash[date1][lunch]
    assert_kind_of MealExemption, hash[date1][dinner]

    assert_kind_of MealExemption, hash[date2][dinner]

    assert_kind_of MealExemption, hash[date3][breakfast]
    assert_kind_of MealExemption, hash[date3][dinner]
  end
end
