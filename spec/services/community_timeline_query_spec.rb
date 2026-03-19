require "rails_helper"

RSpec.describe CommunityTimelineQuery do
  it "returns community and only top-level messages ordered by created_at desc" do
    community = create(:community)
    other_community = create(:community)

    older = create(:message, community: community, created_at: 2.days.ago)
    newer = create(:message, community: community, created_at: 1.day.ago)
    create(:message, community: community, parent_message: newer)
    create(:message, community: other_community)

    result = described_class.new(community_id: community.id).call

    expect(result.community).to eq(community)
    expect(result.messages.map(&:id)).to eq([ newer.id, older.id ])
  end

  it "limits timeline to 50 messages by default" do
    community = create(:community)
    create_list(:message, 55, community: community)

    result = described_class.new(community_id: community.id).call

    expect(result.messages.size).to eq(50)
  end
end
