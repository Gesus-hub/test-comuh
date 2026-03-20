require "rails_helper"

RSpec.describe CommunityTopMessagesQuery do
  it "orders messages by engagement score" do
    community = create(:community)
    low = create(:message, community: community, content: "low")
    high = create(:message, community: community, content: "high")

    create_list(:reaction, 2, message: high, reaction_type: "like")
    create(:message, community: community, parent_message: high, content: "reply 1")
    create(:message, community: community, parent_message: high, content: "reply 2")
    create(:reaction, message: low, reaction_type: "love")

    result = described_class.new(community_id: community.id, limit: 10).call

    expect(result.first.id).to eq(high.id)
    expect(result.first.attributes["reaction_count"].to_i).to eq(2)
    expect(result.first.attributes["reply_count"].to_i).to eq(2)
  end

  it "applies default limit 10 and max limit 50" do
    community = create(:community)
    create_list(:message, 60, community: community)

    default_limited = described_class.new(community_id: community.id).call
    max_limited = described_class.new(community_id: community.id, limit: 500).call

    expect(default_limited.size).to eq(10)
    expect(max_limited.size).to eq(50)
  end
end
