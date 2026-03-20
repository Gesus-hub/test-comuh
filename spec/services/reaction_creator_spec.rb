require "rails_helper"

RSpec.describe ReactionCreator do
  let(:message) { create(:message) }
  let(:user) { create(:user) }

  it "creates reaction and returns aggregated counts" do
    result = described_class.new(
      message_id: message.id,
      user_id: user.id,
      reaction_type: "like"
    ).call

    expect(result.message).to eq(message)
    expect(result.counts["like"]).to eq(1)
  end

  it "raises duplicate error when same user reacts with same type" do
    create(:reaction, message: message, user: user, reaction_type: "love")

    expect do
      described_class.new(
        message_id: message.id,
        user_id: user.id,
        reaction_type: "love"
      ).call
    end.to raise_error(ReactionCreator::DuplicateReactionError)
  end

  it "creates user from username when user_id is not provided" do
    message

    expect do
      described_class.new(
        message_id: message.id,
        username: "new_reactor",
        reaction_type: "insightful"
      ).call
    end.to change(User, :count).by(1)

    created_user = User.find_by!(username: "new_reactor")
    expect(message.reactions.find_by(user_id: created_user.id, reaction_type: "insightful")).to be_present
  end

  it "raises missing user error when user_id and username are absent" do
    expect do
      described_class.new(
        message_id: message.id,
        reaction_type: "like"
      ).call
    end.to raise_error(ReactionCreator::MissingUserError)
  end
end
