require "rails_helper"

RSpec.describe CommunityListQuery do
  it "returns communities ordered by name with aggregated messages_count" do
    beta = create(:community, name: "Beta")
    alpha = create(:community, name: "Alpha")

    create_list(:message, 2, community: beta)
    create(:message, community: alpha)

    result = described_class.new.call.to_a

    expect(result.map(&:name)).to eq([ "Alpha", "Beta" ])

    counts = result.to_h { |community| [ community.id, community.attributes["messages_count"].to_i ] }
    expect(counts[alpha.id]).to eq(1)
    expect(counts[beta.id]).to eq(2)
  end
end
