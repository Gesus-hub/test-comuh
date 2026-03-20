require "rails_helper"

RSpec.describe Community, type: :model do
  it "is valid with name" do
    expect(build(:community)).to be_valid
  end

  it "requires name" do
    expect(build(:community, name: nil)).not_to be_valid
  end

  it "enforces unique name" do
    create(:community, name: "Rails")
    duplicate = build(:community, name: "Rails")

    expect(duplicate).not_to be_valid
  end
end
