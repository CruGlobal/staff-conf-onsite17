FactoryGirl.define do
  factory :user_variable do
    value_type { UserVariable.value_types.keys.sample }
    sequence(:short_name) { |n| format('%s_%d', Faker::File.extension, n) }
    code { Faker::Code.asin }
    description { Faker::Lorem.paragraph(rand(1..3)) }

    value do
      case value_type
      when 'string'
        Faker::Lorem.sentence
      when 'money'
        Money.new(Faker::Number.between(0, 1000_00))
      when 'date'
        Faker::Date.between(10.years.ago, 10.years.from_now)
      when 'number'
        if Faker::Boolean.boolean
          Faker::Number.between(-1000, 1000)
        else
          Faker::Number.between(-1000.0, 1000.0)
        end
      else
        raise "no factory for value_type, #{value_type}"
      end
    end
  end
end
