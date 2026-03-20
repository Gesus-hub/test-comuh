class ReactionCreator
  class DuplicateReactionError < StandardError; end
  class MissingUserError < StandardError; end

  Result = Struct.new(:message, :counts)

  def initialize(message_id:, reaction_type:, user_id: nil, username: nil)
    @message_id = message_id
    @user_id = user_id
    @username = username.to_s
    @reaction_type = reaction_type.to_s
  end

  def call
    message = Message.find(@message_id)
    resolved_user_id = resolve_user_id

    ActiveRecord::Base.transaction do
      message.reactions.create!(user_id: resolved_user_id, reaction_type: @reaction_type)
    end

    Result.new(message, reaction_counts(message))
  rescue ActiveRecord::RecordInvalid => error
    raise error unless duplicate_validation_error?(error)

    raise DuplicateReactionError, "Reaction already exists for user and type"
  rescue ActiveRecord::RecordNotUnique
    raise DuplicateReactionError, "Reaction already exists for user and type"
  end

  private

  def resolve_user_id
    return @user_id if @user_id.present?

    username = @username.strip
    raise MissingUserError, "user_id or username is required" if username.blank?

    User.find_or_create_by!(username: username).id
  end

  def reaction_counts(message)
    grouped = message.reactions.group(:reaction_type).count
    Reaction::REACTION_TYPES.index_with { |type| grouped[type].to_i }
  end

  def duplicate_validation_error?(error)
    record = error.record
    return false unless record.is_a?(Reaction)
    record.errors.full_messages.any? { |message| message.match?(/already been taken/i) }
  end
end
