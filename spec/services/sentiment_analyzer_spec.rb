require "rails_helper"

RSpec.describe SentimentAnalyzer do
  around do |example|
    previous_key = ENV["OPENAI_API_KEY"]
    ENV["OPENAI_API_KEY"] = nil
    example.run
    ENV["OPENAI_API_KEY"] = previous_key
  end

  it "returns positive score for positive text in fallback" do
    score = described_class.call("texto ótimo excelente adorei")
    expect(score).to be > 0
  end

  it "returns negative score for negative text in fallback" do
    score = described_class.call("texto horrível ruim odiei")
    expect(score).to be < 0
  end

  it "stays in range -1.0..1.0" do
    score = described_class.call("bom " * 100)
    expect(score).to be_between(-1.0, 1.0)
  end
end
