require "rails_helper"

RSpec.describe MessageSerializer do
  it "serializes message payload with html" do
    message = create(:message, content: "Mensagem serializada", ai_sentiment_score: 0.7)

    payload = described_class.new(message, html: "<div>message</div>").as_json

    expect(payload).to include(
      id: message.id,
      content: "Mensagem serializada",
      community_id: message.community_id,
      parent_message_id: nil,
      ai_sentiment_score: 0.7,
      html: "<div>message</div>"
    )
    expect(payload[:user]).to eq(
      {
        id: message.user.id,
        username: message.user.username
      }
    )
    expect(payload[:created_at]).to eq(message.created_at.iso8601)
  end
end
