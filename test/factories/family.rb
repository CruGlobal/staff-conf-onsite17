FactoryGirl.define do
  factory :family do
    last_name { Faker::Name.last_name }
    staff_number { Faker::Number.number(10) }
    address1 { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip }
    country_code { Faker::Address.country_code }

    after :create do |family|
      family.housing_preference ||= create(:housing_preference, family: family)
    end

    factory :family_with_members do
      transient do
        attendee_count { 1 + rand(1) }
        child_count { rand(4) }
      end

      after(:create) do |f, params|
        create_list(:attendee_with_meal_exemptions,
                    params.attendee_count, family: f)

        create_list(
          :child_with_meal_exemptions,
          params.child_count,
          family: f,
          last_name: params.last_name
        )
      end
    end
  end
end
