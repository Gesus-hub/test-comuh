require "rails_helper"

RSpec.describe "Api::V1::CommunityMessages", type: :request do
  describe "GET /api/v1/communities/:id/messages/top" do
    it "orders by engagement score and respects limit" do
      community = create(:community)
      low = create(:message, community: community, content: "low")
      high = create(:message, community: community, content: "high")

      create_list(:reaction, 2, message: high, reaction_type: "like")
      create(:message, community: community, parent_message: high, content: "reply 1")
      create(:message, community: community, parent_message: high, content: "reply 2")
      create(:reaction, message: low, reaction_type: "love")

      get "/api/v1/communities/#{community.id}/messages/top", params: { limit: 1 }

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload["messages"].size).to eq(1)
      expect(payload["messages"].first["id"]).to eq(high.id)
      expect(payload["messages"].first["reaction_count"]).to eq(2)
      expect(payload["messages"].first["reply_count"]).to eq(2)
    end
  end
end
