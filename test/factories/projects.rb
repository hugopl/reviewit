FactoryGirl.define do
  factory :project do
    name { Faker::Name.name }
    repository { Faker::Internet.url }
  end
end
