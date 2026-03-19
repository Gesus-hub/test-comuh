class CommunityTopMessageSerializer
  def initialize(message)
    @message = message
  end

  def as_json(*)
    {
      id: @message.id,
      content: @message.content,
      user: {
        id: @message.user.id,
        username: @message.user.username
      },
      ai_sentiment_score: @message.ai_sentiment_score,
      reaction_count: @message.attributes["reaction_count"].to_i,
      reply_count: @message.attributes["reply_count"].to_i,
      engagement_score: @message.attributes["engagement_score"].to_f.round(2)
    }
  end
end
