FactoryBot.define do
  factory :room do
    sequence(:name) { |n| "Sala #{n}" }
    capacity { 10 }
    description { Faker::Lorem.sentence }
    available { true }

    trait :unavailable do
      available { false }
    end
  end
end
