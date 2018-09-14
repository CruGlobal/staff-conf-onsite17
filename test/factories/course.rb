FactoryGirl.define do
  factory :course do
    name { Faker::Educator.course }
    price_cents { Faker::Number.between(0, 1000_00) }
    description { Faker::Lorem.paragraph(rand(1..3)) }
    instructor { Faker::Name.first_name }
    sequence(:ibs_code) { |n| n }
    sequence(:location) { |n| "#{Faker::Address.city} #{n}" }

    # The field doesn't have a strict format. This is just an example.
    week_descriptor do
      week = %w{1 2 3 4 1-2 1-3 1-4 2-3 2-4 3-4}.sample

      start, finish =
        2.times.map { Faker::Number.between(1, 24) }.sort.map do |time|
          Time.strptime(time.to_s, '%H').strftime('%-l%P')
        end

      "Week #{week}, #{start}-#{finish}"
    end
  end
end
