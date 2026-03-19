module Api
  module V1
    class ReactionsController < BaseController
      rescue_from ReactionCreator::DuplicateReactionError do |error|
        render json: { error: error.message }, status: :conflict
      end

      def create
        permitted = reaction_params
        result = ReactionCreator.new(
          message_id: required_param!(permitted, :message_id),
          user_id: permitted[:user_id],
          username: permitted[:username],
          reaction_type: required_param!(permitted, :reaction_type)
        ).call

        render json: ReactionSummarySerializer.new(result).as_json, status: :ok
      end

      private

      def reaction_params
        @reaction_params ||= params.permit(:message_id, :user_id, :username, :reaction_type)
      end
    end
  end
end
