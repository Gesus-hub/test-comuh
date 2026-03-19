require "rails_helper"

RSpec.describe "Api::V1::Analytics", type: :request do
  describe "GET /api/v1/analytics/suspicious_ips" do
    it "returns IPs used by multiple users" do
      community = create(:community)
      ip = "10.10.10.10"

      create(:message, community: community, user: create(:user), user_ip: ip)
      create(:message, community: community, user: create(:user), user_ip: ip)
      create(:message, community: community, user: create(:user), user_ip: ip)
      create(:message, community: community, user: create(:user), user_ip: "8.8.8.8")

      get "/api/v1/analytics/suspicious_ips", params: { min_users: 3 }

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload["suspicious_ips"].size).to eq(1)
      expect(payload["suspicious_ips"].first["ip"]).to eq(ip)
      expect(payload["suspicious_ips"].first["user_count"]).to eq(3)
    end
  end
end
