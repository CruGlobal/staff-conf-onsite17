require 'test_helper'

class PersonTest < ModelTestCase
  setup do
    @person = Person.new(birthdate: 20.years.ago)
  end

  stub_user_variable child_age_cutoff: 6.months.from_now

  test '#age' do
    assert_equal 20, @person.age
  end

  test '#age (memoized) changes after birthdate changes' do
    assert_equal 20, @person.age
    @person.update(birthdate: 40.years.ago)
    assert_equal 40, @person.age
  end
end
