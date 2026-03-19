require "rails_helper"

RSpec.describe SuspiciousIpsQuery do
  it "returns suspicious ips with aggregated usernames" do
    community = create(:community)
    ip = "10.10.10.10"

    user_a = create(:user, username: "alice")
    user_b = create(:user, username: "bob")
    user_c = create(:user, username: "carol")

    create(:message, community: community, user: user_a, user_ip: ip)
    create(:message, community: community, user: user_b, user_ip: ip)
    create(:message, community: community, user: user_c, user_ip: ip)
    create(:message, community: community, user: create(:user), user_ip: "8.8.8.8")

    result = described_class.new(min_users: 3).call

    expect(result.size).to eq(1)
    expect(result.first[:ip]).to eq(ip)
    expect(result.first[:user_count]).to eq(3)
    expect(result.first[:usernames]).to eq(%w[alice bob carol])
  end

  it "uses default min_users = 3 when not provided" do
    community = create(:community)
    ip = "10.1.1.1"

    create(:message, community: community, user: create(:user), user_ip: ip)
    create(:message, community: community, user: create(:user), user_ip: ip)

    result = described_class.new.call

    expect(result).to be_empty
  end
end
