require "rails_helper"

RSpec.describe "Api::V1::Communities", type: :request do
  describe "POST /api/v1/communities" do
    it "creates a community" do
      expect do
        post "/api/v1/communities", params: {
          name: "Nova Comunidade",
          description: "Descrição"
        }, as: :json
      end.to change(Community, :count).by(1)

      expect(response).to have_http_status(:created)
      payload = JSON.parse(response.body)
      expect(payload["name"]).to eq("Nova Comunidade")
      expect(payload["html"]).to be_present
    end
  end
end
