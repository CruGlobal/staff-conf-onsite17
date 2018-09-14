FactoryGirl.define do
  factory :ministry do
    sequence(:name) { |n| "Ministry of #{Faker::Commerce.department} (#{n})" }
    code do
      existing = Ministry.all.pluck(:code)

      c = nil
      while !c || existing.include?(c)
        count = Faker::Number.between(1, 6)
        c = count.times.map { (?A..?Z).to_a.sample }.join
      end
      c
    end
  end
end
