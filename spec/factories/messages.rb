FactoryBot.define do
  factory :message do
    association :user
    association :community
    content { "Mensagem de teste ótima" }
    user_ip { "192.168.1.1" }
    ai_sentiment_score { 0.4 }
    parent_message { nil }
  end
end
