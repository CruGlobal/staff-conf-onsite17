module Import
  class Person
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment

    TRUE_VALUES = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES

    SPREADSHEET_TITLES = {
      person_type: 'Person Type',
      family_tag:  'Family',

      student_number:      'Student Number',
      first_name:          'First',
      last_name:           'Last',
      name_tag_first_name: 'Name Tag Name First',
      name_tag_last_name:  'Name Tag Name Last',
      gender:              'Gender',
      staff_number:        'Staff ID',
      birthdate:           'Birthdate',
      age:                 'Age',
      tshirt_size:         'T-Shirt Size',
      ethnicity:           'Ethnicity',

      mobility_comment: 'Mobility Needs Comment',
      personal_comment: 'Personal Comments',

      address1: 'Address 1',
      address2: 'Address 2',
      city:     'City',
      state:    'State',
      zip:      'ZIP',
      country:  'Country',
      phone:    'Cell',
      email:    'Email',

      conference_choices: 'Conference Choices',
      conference_comment: 'Conference Comments',

      arrived_at:  'Arrival Date',
      departed_at: 'Departure Date',

      housing_type:              'Housing Type Requested',
      housing_beds_count:        'Total Dorm Beds Requested',
      housing_single_room:       'Single room requested',
      housing_roommates:         'Dorm Requested Roommate',
      housing_roommates_email:   'Dorm Requested Roommate Email',
      housing_children_count:    'Apt Number Of Children',
      housing_bedrooms_count:    'Apt Size Requested',
      housing_sharing_requested: 'Apt Sharing Requested',
      housing_accepts_non_ac:    'Accept NON-A/C Apt',
      housing_location1:         'Housing 1st Choice',
      housing_location2:         'Housing 2nd Choice',
      housing_location3:         'Housing 3rd Choice',
      housing_comment:           'Housing Comments',

      grade_level:          'Age Group',
      needs_bed:          'Child Needs Dorm Bed',
      childcare_deposit:  'Childcare Deposit',
      childcare_weeks:    'Child Program Weeks',
      hot_lunch_weeks:    'Hot Lunch Weeks',
      childcare_comment:  'Childcare Comments',

      ibs_courses:  'IBS Courses',
      ibs_comment: 'IBS Comments',

      rec_pass_start_at: 'RecPass Start Date',
      rec_pass_end_at: 'RecPass End Date',

      ministry_code:     'Ministry Code',
      hired_at:          'Hire Date',
      employee_status:   'Employee Status',
      caring_department: 'Caring Department',
      strategy:          'Strategy',
      assignment_length: 'Assignment Length',
      pay_chartfield:    'Pay Chartfield',
      conference_status: 'Conference Status'
    }.freeze

    attr_accessor(*SPREADSHEET_TITLES.keys)

    PERSON_TYPES = {
      'Primary' => Attendee,
      'Spouse' => Attendee,
      'Child' => Child,
      'Additional Family Member' => Child
    }.freeze

    AGE_GROUPS = {
      'Infant / Age 0' => 'age0',
      'Age 1' => 'age1',
      'Age 2' => 'age2',
      'Age 3' => 'age3',
      'Age 4' => 'age4',
      'Age 5 / Kindergarten' => 'age5',
      'Grade 1' => 'grade1',
      'Grade 2' => 'grade2',
      'Grade 3' => 'grade3',
      'Grade 4' => 'grade4',
      'Grade 5' => 'grade5',
      'Grade 6' => 'grade6',
      'Grade 7' => 'grade7',
      'Grade 8' => 'grade8',
      'Grade 9' => 'grade9',
      'Grade 10' => 'grade10',
      'Grade 11' => 'grade11',
      'Grade 12' => 'grade12',
      'Grade 13' => 'grade13',
      'Post High School' => 'postHighSchool'
    }.freeze

    validates :person_type, :first_name, :last_name, :family_tag, presence: true
    validates :gender, inclusion: { in: ::Person::GENDERS.keys.map(&:to_s) }

    # @return [Boolean] if this person holds the family/address details for
    # their family
    def primary_family_member?
      person_type == 'Primary'
    end

    # @return [ApplicationRecord] the record class which this imported person
    #   represents
    def record_class
      PERSON_TYPES[person_type] || Child
    end

    def gender=(gender)
      @gender = gender&.downcase || 'm'
    end

    def country_code
      ISO3166::Country.find_country_by_alpha3(country)&.alpha2
    end

    def housing_roommates_details
      if housing_roommates_email.present?
        format('%s <%s>', housing_roommates, housing_roommates_email)
      else
        housing_roommates
      end
    end

    def family_record
      Family.includes(:people, :housing_preference).find_by(import_tag: family_tag)
    end

    def housing_single_room=(str)
      @housing_single_room = true_string?(str)
    end

    def housing_accepts_non_ac=(str)
      @housing_accepts_non_ac = true_string?(str)
    end

    def needs_bed=(str)
      @needs_bed = true_string?(str)
    end

    def grade_level=(group)
      @grade_level =
        if (match = AGE_GROUPS[group])
          match
        elsif group.present?
          # go in reverse to match "Grade 10" before "Grade 1"
          AGE_GROUPS.reverse_each.find { |k, _| group.include?(k) }&.last
        end
    end

    def childcare_deposit=(str)
      # weird one: "-1" seems to be true and ""/"0" are false
      @childcare_deposit = str.present? && str != '0'
    end

    def housing_type=(type)
      @housing_type =
        case type&.downcase
        when /dorm/ then :dormitory
        when /apartment/ then :apartment
        else :self_provided
        end
    end

    private

    def true_string?(str)
      str&.downcase == 'yes' || TRUE_VALUES.include?(str)
    end
  end
end
