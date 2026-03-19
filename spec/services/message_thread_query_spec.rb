require "rails_helper"

RSpec.describe MessageThreadQuery do
  it "loads message with user, reactions and replies associations" do
    message = create(:message)
    create(:reaction, message: message)
    create(:message, community: message.community, parent_message: message)

    result = described_class.new(message_id: message.id).call

    expect(result).to eq(message)
    expect(result.association(:user).loaded?).to be(true)
    expect(result.association(:reactions).loaded?).to be(true)
    expect(result.association(:replies).loaded?).to be(true)
  end
end
