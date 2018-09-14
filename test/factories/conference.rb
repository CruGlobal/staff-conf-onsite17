FactoryGirl.define do
  factory :conference do
    name { Faker::Educator.course }
    description { Faker::Lorem.paragraph(rand(3)) }
    price_cents { Faker::Number.between(0, 1000_00) }
    start_at { Faker::Date.between(1.year.ago, 1.year.from_now) }
    end_at { Faker::Date.between(start_at + 1.day, 1.year.from_now + 1.day) }
  end
end
