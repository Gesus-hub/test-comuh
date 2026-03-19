class MessageThreadQuery
  def initialize(message_id:)
    @message_id = message_id
  end

  def call
    Message
      .includes(:user, :reactions, replies: [ :user, :reactions ])
      .find(@message_id)
  end
end
