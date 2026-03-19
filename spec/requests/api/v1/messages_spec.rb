require "rails_helper"

RSpec.describe "Api::V1::Messages", type: :request do
  describe "POST /api/v1/messages" do
    let(:community) { create(:community) }

    it "creates message and user when username does not exist" do
      expect do
        post "/api/v1/messages", params: {
          username: "john_doe",
          community_id: community.id,
          content: "mensagem ótima",
          user_ip: "192.168.0.1"
        }, as: :json
      end.to change(Message, :count).by(1)
        .and change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      payload = JSON.parse(response.body)
      expect(payload["user"]["username"]).to eq("john_doe")
      expect(payload["community_id"]).to eq(community.id)
      expect(payload["ai_sentiment_score"]).to be_between(-1.0, 1.0)
      expect(payload["html"]).to be_present
    end

    it "returns 422 when parent message belongs to another community" do
      another_community = create(:community)
      parent = create(:message, community: another_community)

      post "/api/v1/messages", params: {
        username: "john_doe",
        community_id: community.id,
        content: "comentário",
        user_ip: "192.168.0.1",
        parent_message_id: parent.id
      }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
