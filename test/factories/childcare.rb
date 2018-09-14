FactoryGirl.define do
  factory :childcare do
    name { Faker::Educator.course }
    teachers { rand(4).times.map { Faker::Name.name }.to_sentence }
    location { Faker::Address.street_address }
  end
end
