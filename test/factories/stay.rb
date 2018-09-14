FactoryGirl.define do
  factory :stay do
    person { create(Faker::Boolean.boolean ? :attendee : :child) }
    housing_unit
    single_occupancy { Faker::Boolean.boolean }
    no_charge { Faker::Boolean.boolean }
    waive_minimum { Faker::Boolean.boolean }
    percentage { Faker::Number.between(0, 100) }

    arrived_at  { Faker::Date.between(1.year.from_now, 2.years.from_now) }
    departed_at { arrived_at + rand(0.0..(365.2525 * 2)).days }
  end
end
