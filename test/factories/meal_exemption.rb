FactoryGirl.define do
  factory :meal_exemption do
    person { build(Faker::Boolean.boolean ? :attendee : :child) }
    date { Faker::Date.between(1.year.ago, 1.year.from_now) }
    meal_type { MealExemption::TYPES.sample }
  end
end
