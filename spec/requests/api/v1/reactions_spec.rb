require "rails_helper"

RSpec.describe "Api::V1::Reactions", type: :request do
  describe "POST /api/v1/reactions" do
    let(:message) { create(:message) }
    let(:user) { create(:user) }

    it "creates reaction and returns grouped counters" do
      post "/api/v1/reactions", params: {
        message_id: message.id,
        user_id: user.id,
        reaction_type: "like"
      }, as: :json

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload["reactions"]["like"]).to eq(1)
      expect(payload["reactions"]["love"]).to eq(0)
    end

    it "returns conflict for duplicate reaction type from same user" do
      create(:reaction, message: message, user: user, reaction_type: "insightful")

      post "/api/v1/reactions", params: {
        message_id: message.id,
        user_id: user.id,
        reaction_type: "insightful"
      }, as: :json

      expect(response).to have_http_status(:conflict)
    end

    it "accepts username instead of user_id" do
      post "/api/v1/reactions", params: {
        message_id: message.id,
        reaction_type: "love",
        username: "new_reactor"
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(User.find_by(username: "new_reactor")).to be_present
    end
  end
end
