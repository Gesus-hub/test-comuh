class CommunitiesController < ApplicationController
  def index
    @communities = CommunityListQuery.new.call
  end

  def show
    result = CommunityTimelineQuery.new(community_id: params[:id]).call
    @community = result.community
    @messages = result.messages
  end
end
