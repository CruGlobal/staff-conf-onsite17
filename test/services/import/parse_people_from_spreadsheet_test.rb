require 'test_helper'

class Import::ParsePeopleFromSpreadsheetTest < ServiceTestCase
  setup do
    @results_single_primary =
      import_spreadsheet('people-import--single-primary.xlsx')
  end

  test 'single primary person, verbatim column/attribute mapping' do
    @person = @results_single_primary.import_people.first

    assert_equal 'Primary', @person.person_type
    assert_equal 'Abbott-65ad', @person.family_tag
    assert_equal 'Duane', @person.first_name
    assert_equal 'Abbott', @person.last_name
    assert_equal 'Duane', @person.name_tag_first_name
    assert_equal 'Abbott', @person.name_tag_last_name
    assert_equal 'm', @person.gender
    assert_equal '0638533', @person.staff_number
    assert_equal Date.parse('1967-05-10'), @person.birthdate
    assert_equal 'White', @person.ethnicity
    assert_equal '114 Mountain Valley Dr', @person.address1
    assert_equal 'Maumelle', @person.city
    assert_equal 'AR', @person.state
    assert_equal '72113', @person.zip
    assert_equal 'USA', @person.country
    assert_equal '5154738402', @person.phone
    assert_equal 'dabbott@familylife.com', @person.email
    assert_equal 'FL33230', @person.ministry_code
    assert_equal Date.parse('2012-02-01'), @person.hired_at
    assert_equal 'Staff Full Time', @person.employee_status
    assert_equal 'STFFD.LH.STAFF', @person.pay_chartfield
    assert_equal 'Registered', @person.conference_status
  end

  test '#primary_family_member? for single primary person' do
    @person = @results_single_primary.import_people.first
    assert @person.primary_family_member?, 'should be the Primary member'
  end

  test '#record_class for single primary person' do
    @person = @results_single_primary.import_people.first
    assert_equal Attendee, @person.record_class
  end

  private

  def import_spreadsheet(filename)
    path = Rails.root.join('test', 'fixtures', filename)

    job = UploadJob.create!(filename: path, user_id: 1)
    spreadsheet = ReadSpreadsheet.call(job: job)

    Import::ParsePeopleFromSpreadsheet.call(job: job,
                                            sheets: spreadsheet.sheets)
  end
end
