class MessageHtmlRenderer
  def self.call(controller:, message:, comment_level: 1)
    new(controller: controller, message: message, comment_level: comment_level).call
  end

  def initialize(controller:, message:, comment_level:)
    @controller = controller
    @message = message
    @comment_level = comment_level
  end

  def call
    if @message.parent_message_id.present?
      @controller.render_to_string(
        partial: "messages/comment",
        formats: [ :html ],
        locals: { comment: @message, level: @comment_level }
      )
    else
      @controller.render_to_string(
        partial: "messages/message",
        formats: [ :html ],
        locals: { message: @message }
      )
    end
  end
end
