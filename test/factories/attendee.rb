using InternationalPhoneNumber

FactoryGirl.define do
  factory :attendee do
    family
    ministry
    seminary

    first_name { Faker::Name.first_name }
    last_name { Faker::Boolean.boolean(0.9) ? nil : Faker::Name.last_name }
    email { Faker::Internet.email }
    emergency_contact { [true, false].sample }
    phone { Faker::PhoneNumber.international }
    birthdate do
      if Faker::Boolean.boolean(0.9)
        Faker::Date.between(75.years.ago, 18.years.ago)
      end
    end
    student_number { Faker::Number.number(10) }
    gender { Person::GENDERS.keys.sample }

    [:arrived_at, :departed_at, :rec_pass_start_at].each do |attr|
      add_attribute(attr) { maybe { random_future_date } }
    end

    rec_pass_end_at do
      random_future_date(rec_pass_start_at) if rec_pass_start_at
    end

    conference_status { Attendee::CONFERENCE_STATUSES.sample }

    factory :attendee_with_meal_exemptions do
      transient do
        count 20
      end

      after(:create) do |attendee, params|
        create_list(:meal_exemption, params.count, person: attendee)
      end
    end
  end
end
