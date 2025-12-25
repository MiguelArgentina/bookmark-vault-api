FactoryBot.define do
  factory :bookmark do
    association :user
    title { Faker::Internet.domain_word.titleize }
    url { Faker::Internet.url(host: "example.com") }
    tag { Faker::Lorem.word }
  end
end