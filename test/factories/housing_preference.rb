FactoryGirl.define do
  factory :housing_preference do
    family
    housing_type { HousingFacility.housing_types.values.sample }
    location1 { Faker::Address.street_address }
    location2 { Faker::Address.street_address }
    location3 { Faker::Address.street_address }
    beds_count { Faker::Number.between(0, 3) }
    children_count { Faker::Number.between(0, 6) }
    bedrooms_count { Faker::Number.between(0, 4) }

    roommates do
      Faker::Number.between(0, 3).times.map do
        Faker::Name.name
      end.join("\n")
    end

    confirmed_at do
      if Faker::Boolean.boolean
        Faker::Date.between(1.year.ago, 1.day.ago)
      end
    end
  end
end
