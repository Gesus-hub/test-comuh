require "rails_helper"

RSpec.describe SuspiciousIpSerializer do
  it "serializes suspicious ip payload" do
    payload = described_class.new(
      ip: "192.168.1.10",
      user_count: "3",
      usernames: %w[user1 user2 user3]
    ).as_json

    expect(payload).to eq(
      {
        ip: "192.168.1.10",
        user_count: 3,
        usernames: %w[user1 user2 user3]
      }
    )
  end
end
