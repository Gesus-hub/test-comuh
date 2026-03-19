require "rails_helper"

RSpec.describe MessageCreator do
  let(:community) { create(:community) }

  it "creates user automatically when username does not exist" do
    expect do
      described_class.new(
        username: "new_user",
        community_id: community.id,
        content: "conteúdo ótimo",
        user_ip: "10.1.1.1"
      ).call
    end.to change(User, :count).by(1)
  end

  it "creates a message with sentiment score" do
    result = described_class.new(
      username: "author_1",
      community_id: community.id,
      content: "mensagem legal",
      user_ip: "10.1.1.1"
    ).call

    expect(result.message).to be_persisted
    expect(result.message.ai_sentiment_score).to be_between(-1.0, 1.0)
  end

  it "raises error when parent belongs to another community" do
    other_community = create(:community)
    parent = create(:message, community: other_community)

    creator = described_class.new(
      username: "author_2",
      community_id: community.id,
      content: "comentário",
      user_ip: "10.1.1.1",
      parent_message_id: parent.id
    )

    expect { creator.call }.to raise_error(MessageCreator::ParentCommunityMismatchError)
  end
end
