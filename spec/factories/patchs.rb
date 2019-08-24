FactoryBot.define do
  factory :patch do
    description { Faker::Lorem.sentence }
    commit_message { Faker::Lorem.sentence }
    subject { Faker::Lorem.sentence }
    diff { 'some diff here in the future' }
  end
end
