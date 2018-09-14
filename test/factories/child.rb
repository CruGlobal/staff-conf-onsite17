FactoryGirl.define do
  factory :child do
    family

    first_name { Faker::Name.first_name }
    last_name { Faker::Boolean.boolean(0.9) ? nil : Faker::Name.last_name }
    birthdate do
      if Faker::Boolean.boolean(0.9)
        Faker::Date.between(12.years.ago, 1.years.ago)
      end
    end
    gender { Person::GENDERS.keys.sample }

    [:arrived_at, :departed_at, :rec_pass_start_at].each do |attr|
      add_attribute(attr) { maybe { random_future_date } }
    end

    rec_pass_end_at do
      random_future_date(rec_pass_start_at) if rec_pass_start_at
    end

    grade_level { Child::GRADE_LEVELS.sample }
    childcare_deposit false

    after(:build) do |child|
      # A random number of random weeks
      child.childcare_weeks do
        if child.too_old_for_childcare?
          nil
        else
          count = Childcare::CHILDCARE_WEEKS.size
          samples = Faker::Number.between(0, count)
          (0...count).to_a.shuffle[0...samples]
        end
      end
    end

    trait :childcare do
      grade_level { Child.childcare_grade_levels.sample }
    end

    trait :senior do
      grade_level { Child.senior_grade_levels.sample }
    end

    factory :child_with_meal_exemptions do
      transient do
        count 20
      end

      after(:create) do |child, params|
        create_list(:meal_exemption, params.count, person: child)
      end
    end
  end
end
