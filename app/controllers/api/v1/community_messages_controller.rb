module Api
  module V1
    class CommunityMessagesController < BaseController
      def top
        messages = CommunityTopMessagesQuery.new(
          community_id: params[:id],
          limit: params[:limit]
        ).call

        render json: {
          messages: messages.map { |message| CommunityTopMessageSerializer.new(message).as_json }
        }
      end
    end
  end
end
