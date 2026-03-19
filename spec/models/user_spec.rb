require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with username" do
    expect(build(:user)).to be_valid
  end

  it "requires username" do
    expect(build(:user, username: nil)).not_to be_valid
  end

  it "enforces unique username" do
    create(:user, username: "same_name")
    duplicate = build(:user, username: "same_name")

    expect(duplicate).not_to be_valid
  end
end
