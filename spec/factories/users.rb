FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :member }

    trait :admin do
      role { :admin }
    end
  end
end
