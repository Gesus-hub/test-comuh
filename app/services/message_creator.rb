class MessageCreator
  class ParentCommunityMismatchError < StandardError; end

  Result = Struct.new(:message)

  def initialize(username:, community_id:, content:, user_ip:, parent_message_id: nil)
    @username = username.to_s.strip
    @community_id = community_id
    @content = content.to_s
    @user_ip = user_ip.to_s
    @parent_message_id = parent_message_id
  end

  def call
    message = nil

    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(username: @username)
      community = Community.find(@community_id)
      parent = @parent_message_id.present? ? Message.find(@parent_message_id) : nil

      validate_parent_community!(parent, community)

      message = Message.new(
        user: user,
        community: community,
        parent_message: parent,
        content: @content,
        user_ip: @user_ip,
        ai_sentiment_score: SentimentAnalyzer.call(@content)
      )

      message.save!
    end

    Result.new(message)
  end

  private

  def validate_parent_community!(parent, community)
    return if parent.nil?
    return if parent.community_id == community.id

    raise ParentCommunityMismatchError, "Parent message must belong to the same community"
  end
end
