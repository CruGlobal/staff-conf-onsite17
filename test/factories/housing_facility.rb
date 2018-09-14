FactoryGirl.define do
  factory :housing_facility do
    association :cost_code, factory: :cost_code_with_long_max_days

    housing_type do
      HousingFacility.housing_types.
        keys.
        reject { |type| type == 'self_provided' }.
        sample
    end
    name { Faker::University.name }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip }
    country_code { Faker::Address.country_code }

    factory :apartment do
      housing_type 'apartment'
      association :cost_code, factory: :cost_code_with_long_max_days, min_days: 1
    end

    factory :dormitory do
      housing_type 'dormitory'
      association :cost_code, factory: :cost_code_with_long_max_days, min_days: 1
    end

    factory :housing_facility_with_units do
      transient do
        count 20
      end

      after(:create) do |hf, params|
        create_list(:housing_unit, params.count, housing_facility: hf)
      end
    end
  end
end
