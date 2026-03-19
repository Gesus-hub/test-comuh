require "rails_helper"

RSpec.describe CommunityCardHtmlRenderer do
  it "renders community card partial with messages_count" do
    controller = instance_double(Api::V1::CommunitiesController)
    community = build(:community)

    expect(controller).to receive(:render_to_string).with(
      partial: "communities/community_card",
      formats: [ :html ],
      locals: { community: community, messages_count: 5 }
    ).and_return("<div>community</div>")

    html = described_class.call(controller: controller, community: community, messages_count: 5)

    expect(html).to eq("<div>community</div>")
  end
end
