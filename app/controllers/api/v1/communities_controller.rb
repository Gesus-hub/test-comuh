module Api
  module V1
    class CommunitiesController < BaseController
      def create
        community = Community.create!(community_params)
        render json: CommunitySerializer.new(
          community,
          html: CommunityCardHtmlRenderer.call(controller: self, community: community, messages_count: 0)
        ).as_json, status: :created
      end

      private

      def community_params
        params.permit(:name, :description)
      end
    end
  end
end
