class MessageSerializer
  def initialize(message, html: nil)
    @message = message
    @html = html
  end

  def as_json(*)
    payload = {
      id: @message.id,
      content: @message.content,
      user: {
        id: @message.user.id,
        username: @message.user.username
      },
      community_id: @message.community_id,
      parent_message_id: @message.parent_message_id,
      ai_sentiment_score: @message.ai_sentiment_score,
      created_at: @message.created_at.iso8601
    }
    payload[:html] = @html unless @html.nil?
    payload
  end
end
