module Api
  module V1
    class MessagesController < BaseController
      def create
        permitted = message_params
        result = MessageCreator.new(
          username: required_param!(permitted, :username),
          community_id: required_param!(permitted, :community_id),
          content: required_param!(permitted, :content),
          user_ip: resolved_user_ip,
          parent_message_id: permitted[:parent_message_id]
        ).call

        render json: MessageSerializer.new(
          result.message,
          html: MessageHtmlRenderer.call(controller: self, message: result.message)
        ).as_json, status: :created
      end

      private

      def message_params
        @message_params ||= params.permit(:username, :community_id, :content, :user_ip, :parent_message_id)
      end

      def resolved_user_ip
        message_params[:user_ip].presence || request.remote_ip
      end
    end
  end
end
