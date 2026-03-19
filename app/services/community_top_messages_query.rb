class CommunityTopMessagesQuery
  DEFAULT_LIMIT = 10
  MAX_LIMIT = 50

  def initialize(community_id:, limit: nil)
    @community_id = community_id
    @limit = limit
  end

  def call
    community = Community.find(@community_id)
    ranked_messages_for(community).limit(normalized_limit)
  end

  private

  def normalized_limit
    raw = @limit.to_i
    return DEFAULT_LIMIT if raw <= 0

    [ raw, MAX_LIMIT ].min
  end

  def ranked_messages_for(community)
    reaction_counts = Reaction
      .select("message_id, COUNT(*) AS reaction_count")
      .group(:message_id)

    reply_counts = Message
      .where.not(parent_message_id: nil)
      .select("parent_message_id AS message_id, COUNT(*) AS reply_count")
      .group(:parent_message_id)

    community.messages
      .top_level
      .joins("LEFT JOIN (#{reaction_counts.to_sql}) rc ON rc.message_id = messages.id")
      .joins("LEFT JOIN (#{reply_counts.to_sql}) rp ON rp.message_id = messages.id")
      .includes(:user)
      .select(
        "messages.*,
         COALESCE(rc.reaction_count, 0) AS reaction_count,
         COALESCE(rp.reply_count, 0) AS reply_count,
         (COALESCE(rc.reaction_count, 0) * 1.5 + COALESCE(rp.reply_count, 0)) AS engagement_score"
      )
      .order(Arel.sql("engagement_score DESC, messages.created_at DESC"))
  end
end
