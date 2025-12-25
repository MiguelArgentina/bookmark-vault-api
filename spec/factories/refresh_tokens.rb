FactoryBot.define do
  factory :refresh_token do
    association :user
    token_digest { Faker::Alphanumeric.alphanumeric(number: 64) }
    expires_at { 30.days.from_now }
    revoked_at { nil }
    replaced_by_id { nil }
  end
end