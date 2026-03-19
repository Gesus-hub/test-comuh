require "rails_helper"

RSpec.describe Reaction, type: :model do
  it "is valid with allowed reaction_type" do
    expect(build(:reaction, reaction_type: "like")).to be_valid
  end

  it "rejects unknown reaction_type" do
    expect(build(:reaction, reaction_type: "wow")).not_to be_valid
  end

  it "enforces uniqueness for same user/message/type" do
    reaction = create(:reaction, reaction_type: "love")
    duplicate = build(:reaction, message: reaction.message, user: reaction.user, reaction_type: "love")

    expect(duplicate).not_to be_valid
  end
end
