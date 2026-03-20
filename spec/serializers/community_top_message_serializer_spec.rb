require "rails_helper"

RSpec.describe CommunityTopMessageSerializer do
  it "serializes ranked message with computed fields" do
    message = create(:message, content: "Top message", ai_sentiment_score: 0.5)
    attributes = message.attributes.merge(
      "reaction_count" => "4",
      "reply_count" => "2",
      "engagement_score" => "8.0"
    )
    allow(message).to receive(:attributes).and_return(attributes)

    payload = described_class.new(message).as_json

    expect(payload).to eq(
      {
        id: message.id,
        content: "Top message",
        user: {
          id: message.user.id,
          username: message.user.username
        },
        ai_sentiment_score: 0.5,
        reaction_count: 4,
        reply_count: 2,
        engagement_score: 8.0
      }
    )
  end
end
