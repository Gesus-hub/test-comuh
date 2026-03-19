class ReactionSummarySerializer
  def initialize(result)
    @result = result
  end

  def as_json(*)
    {
      message_id: @result.message.id,
      reactions: @result.counts
    }
  end
end
