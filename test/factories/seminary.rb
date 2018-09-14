FactoryGirl.define do
  factory :seminary do
    name { Faker::University.name }
    sequence(:code) { |i| format('%d_%s', i, Faker::Bank.swift_bic) }
    course_price_cents { Faker::Number.number(4) }

    factory :seminary_with_attendees do
      after(:create) do |seminary|
        create_list :attendee, 3, seminary: seminary
      end
    end
  end
end
