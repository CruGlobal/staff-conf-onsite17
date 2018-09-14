require 'test_helper'

class UserVariableTest < ModelTestCase
  UserVariable.value_types.each do |type, _|
    test "expect method load_#{type} to exist" do
      assert UserVariable.new.respond_to?("load_#{type}".to_sym, true),
        "expected class to have method load_#{type}"
    end
  end

  test 'basic get' do
    create(:user_variable, short_name: :basic_get_test, value_type: 'money',
                           value: Money.new(123_45))

    assert_equal Money.new(123_45), UserVariable[:basic_get_test]
  end

  test 'unknown user variable' do
    assert_raise(ArgumentError) { UserVariable[:something_weird] }
  end

  test '#value types match #value_type' do
    assert_kind_of String,  create(:user_variable, value_type: 'string').value
    assert_kind_of Money,   create(:user_variable, value_type: 'money').value
    assert_kind_of Date,    create(:user_variable, value_type: 'date').value
    assert_kind_of Numeric, create(:user_variable, value_type: 'number').value
  end

  test 'valid money values' do
    create(:user_variable, value_type: 'money', value: 123_45)
    create(:user_variable, value_type: 'money', value: Money.new(123_45))
  end

  test 'invalid money values' do
    assert_raise ArgumentError do
      create(:user_variable, value_type: 'money', value: 'hello')
    end
    assert_raise ArgumentError do
      create(:user_variable, value_type: 'money', value: '2017-01-01')
    end
  end

  test 'valid date values' do
    create(:user_variable, value_type: 'date', value: '2018-02-03')
    create(:user_variable, value_type: 'date', value: Date.today)
  end

  test 'invalid date values' do
    assert_raise ArgumentError do
      create(:user_variable, value_type: 'date', value: 'hello')
    end
    assert_raise ArgumentError do
      create(:user_variable, value_type: 'date', value: 1234)
    end
  end

  test 'valid number values' do
    create(:user_variable, value_type: 'number', value: '123')
    create(:user_variable, value_type: 'number', value: 123)
  end

  test 'invalid number values' do
    assert_raise ArgumentError do
      create(:user_variable, value_type: 'number', value: 'hello')
    end
    assert_raise ArgumentError do
      create(:user_variable, value_type: 'number', value: Date.today)
    end
  end

  test 'basic set' do
    create(:user_variable, short_name: :test, value_type: 'money',
                           value: Money.new(123_45))

    UserVariable[:test] = Money.new(100_23)

    assert_equal Money.new(100_23), UserVariable[:test]
  end

  test 'attempting to set a non-existant variable' do
    assert_raise(ArgumentError) { UserVariable[:test] = Money.new(100_23) }
  end

  test 'attempting to set a variable with an illegal value' do
    create(:user_variable, short_name: :test, value_type: 'money',
                           value: Money.new(123_45))

    assert_raise(ArgumentError) { UserVariable[:test] = 'some text' }
  end
end
