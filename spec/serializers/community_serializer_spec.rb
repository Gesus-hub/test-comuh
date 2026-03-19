require "rails_helper"

RSpec.describe CommunitySerializer do
  it "serializes community with optional html" do
    community = create(:community, name: "Ruby", description: "Backend")

    payload = described_class.new(community, html: "<div>card</div>").as_json

    expect(payload).to eq(
      {
        id: community.id,
        name: "Ruby",
        description: "Backend",
        html: "<div>card</div>"
      }
    )
  end

  it "omits nil fields" do
    community = create(:community)

    payload = described_class.new(community).as_json

    expect(payload).not_to have_key(:html)
  end
end
