FactoryBot.define do
  factory :community do
    sequence(:name) { |n| "Community #{n}" }
    description { "Descrição da comunidade" }
  end
end
