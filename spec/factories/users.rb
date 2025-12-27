FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password_digest { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
