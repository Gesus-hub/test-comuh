require "rails_helper"

RSpec.describe ReactionSummarySerializer do
  it "serializes reaction creator result" do
    message = create(:message)
    result = ReactionCreator::Result.new(message, { "like" => 2, "love" => 1, "insightful" => 0 })

    payload = described_class.new(result).as_json

    expect(payload).to eq(
      {
        message_id: message.id,
        reactions: { "like" => 2, "love" => 1, "insightful" => 0 }
      }
    )
  end
end
