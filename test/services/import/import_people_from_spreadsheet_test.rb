require 'test_helper'

class Import::ImportPeopleFromSpreadsheetTest < ServiceTestCase
  def around(&blk)
    create :conference, name: 'Cru17'
    stub_default_seminary(&blk)
  end

  test 'single primary person, should create new Attendee' do
    assert_difference ->{ Attendee.count }, +1 do
      import_spreadsheet('people-import--single-primary.xlsx')
    end

    @person = Attendee.last
    assert_equal 'Duane', @person.first_name
    assert_equal 'Abbott', @person.last_name
    assert_equal 'Duane', @person.name_tag_first_name
    assert_equal 'Abbott', @person.name_tag_last_name
    assert_equal 'm', @person.gender
    assert_equal Date.parse('1967-05-10'), @person.birthdate
    assert_equal 'White', @person.ethnicity
    assert_equal '5154738402', @person.phone
    assert_equal 'dabbott@familylife.com', @person.email
    assert_equal Date.parse('2012-02-01'), @person.hired_at
    assert_equal 'Staff Full Time', @person.employee_status
    assert_equal 'STFFD.LH.STAFF', @person.pay_chartfield
    assert_equal 'Registered', @person.conference_status
  end

  test 'single primary person, should create Family' do
    assert_difference ->{ Family.count }, +1 do
      import_spreadsheet('people-import--single-primary.xlsx')
    end

    @family = Family.last
    assert_equal 'Abbott-65ad', @family.import_tag
    assert_equal '0638533', @family.staff_number
    assert_equal '114 Mountain Valley Dr', @family.address1
    assert_equal 'Maumelle', @family.city
    assert_equal 'AR', @family.state
    assert_equal '72113', @family.zip
    assert_equal 'US', @family.country_code
  end

  private

  def stub_default_seminary(&blk)
    Seminary.stub(:default, create(:seminary), &blk)
  end

  def import_spreadsheet(filename)
    path = Rails.root.join('test', 'fixtures', filename)

    Import::ImportPeopleFromSpreadsheet.call(
      job: UploadJob.create!(filename: path, user_id: 1)
    )
  end
end
