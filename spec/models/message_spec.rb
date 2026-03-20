require "rails_helper"

RSpec.describe Message, type: :model do
  it "is valid with required attributes" do
    expect(build(:message)).to be_valid
  end

  it "requires content" do
    expect(build(:message, content: nil)).not_to be_valid
  end

  it "requires user_ip" do
    expect(build(:message, user_ip: nil)).not_to be_valid
  end

  it "allows parent_message to be nil" do
    expect(build(:message, parent_message: nil)).to be_valid
  end

  it "accepts sentiment score between -1.0 and 1.0" do
    expect(build(:message, ai_sentiment_score: 0.7)).to be_valid
    expect(build(:message, ai_sentiment_score: -2.0)).not_to be_valid
  end
end
