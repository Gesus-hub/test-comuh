class SentimentAnalyzer
  OPENAI_URL = "https://api.openai.com/v1/responses".freeze
  DEFAULT_MODEL = "gpt-4.1-nano".freeze

  POSITIVE_WORDS = %w[
    bom ótima otimo excelente legal gostei feliz amor adoro incrível incrivel
    perfeito top parabéns parabens sucesso útil util
  ].freeze

  NEGATIVE_WORDS = %w[
    ruim péssimo pessimo horrível horrivel odiei triste raiva terrível terrivel
    lixo ruimzinho péssima pessima inútil inutil
  ].freeze

  def self.call(content)
    new(content).call
  end

  def initialize(content)
    @content = content.to_s
  end

  def call
    return fallback_score if @content.blank?
    return fallback_score unless openai_enabled?

    score = fetch_openai_score
    score.nil? ? fallback_score : clamp(score)
  rescue StandardError
    fallback_score
  end

  private

  def openai_enabled?
    ENV["OPENAI_API_KEY"].present?
  end

  def fetch_openai_score
    response = Faraday.post(OPENAI_URL) do |req|
      req.headers["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
      req.headers["Content-Type"] = "application/json"
      req.body = request_body.to_json
    end

    return nil unless response.success?

    body = JSON.parse(response.body)
    text = body["output_text"].to_s
    float_from(text)
  rescue JSON::ParserError
    nil
  end

  def request_body
    {
      model: ENV.fetch("OPENAI_SENTIMENT_MODEL", DEFAULT_MODEL),
      input: [
        {
          role: "system",
          content: [
            {
              type: "input_text",
              text: "Responda APENAS com um número float entre -1.0 e 1.0 para o sentimento."
            }
          ]
        },
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: @content
            }
          ]
        }
      ],
      temperature: 0,
      max_output_tokens: 12
    }
  end

  def float_from(text)
    matched = text.match(/-?\d+(?:\.\d+)?/)
    matched ? matched[0].to_f : nil
  end

  def fallback_score
    words = @content.downcase.scan(/\p{L}+/)
    return 0.0 if words.empty?

    positives = words.count { |word| POSITIVE_WORDS.include?(word) }
    negatives = words.count { |word| NEGATIVE_WORDS.include?(word) }
    clamp((positives - negatives).to_f / [ words.size, 1 ].max)
  end

  def clamp(value)
    [ [ value.to_f, -1.0 ].max, 1.0 ].min.round(4)
  end
end
