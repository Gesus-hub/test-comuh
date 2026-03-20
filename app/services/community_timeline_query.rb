class CommunityTimelineQuery
  DEFAULT_LIMIT = 50

  Result = Struct.new(:community, :messages)

  def initialize(community_id:, limit: DEFAULT_LIMIT)
    @community_id = community_id
    @limit = limit
  end

  def call
    community = Community.find(@community_id)
    messages = community.messages
      .top_level
      .includes(:user, :reactions, replies: [ :user, :reactions ])
      .order(created_at: :desc)
      .limit(@limit)

    Result.new(community, messages)
  end
end
