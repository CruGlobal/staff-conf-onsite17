FactoryGirl.define do
  factory :housing_unit do
    housing_facility
    sequence(:name) { |n| format("%s%03d", (?A..?Z).to_a.sample, n) }

    factory :dormitory_unit do
      association :housing_facility, factory: :dormitory
    end

    factory :apartment_unit do
      association :housing_facility, factory: :apartment
    end
  end
end
