require 'test_helper'

class Import::PersonTest < ModelTestCase
  test '#primary_family_member?' do
    assert Import::Person.new(person_type: 'Primary').primary_family_member?
    refute Import::Person.new(person_type: 'Spouse').primary_family_member?
    refute Import::Person.new(person_type: 'Child').primary_family_member?
    refute Import::Person.new(person_type: 'Additional Family Member').primary_family_member?
  end

  test '#record_class' do
    assert_equal Attendee, Import::Person.new(person_type: 'Primary').record_class
    assert_equal Attendee, Import::Person.new(person_type: 'Spouse').record_class
    assert_equal Child, Import::Person.new(person_type: 'Child').record_class
    assert_equal Child, Import::Person.new(person_type: 'Additional Family Member').record_class
  end

  test '#country_code' do
    assert_equal 'US', Import::Person.new(country: 'USA').country_code
    assert_equal 'CA', Import::Person.new(country: 'CAN').country_code
    assert_equal 'BA', Import::Person.new(country: 'BIH').country_code
  end
end
