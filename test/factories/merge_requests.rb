FactoryBot.define do
  factory :merge_request do
    subject { Faker::Name.name }
    target_branch { Faker::App.version }

    association :project
    association :author, factory: :user
  end
end
