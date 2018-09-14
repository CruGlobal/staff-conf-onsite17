FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    role { User::ROLES.sample }
    guid { Faker::Number.hexadecimal(8) }

    factory :admin_user do
      role 'admin'
    end

    factory :general_user do
      role 'general'
    end

    factory :finance_user do
      role 'finance'
    end

    factory :read_only_user do
      role 'read_only'
    end
  end
end
