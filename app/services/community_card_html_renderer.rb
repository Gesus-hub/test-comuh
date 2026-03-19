class CommunityCardHtmlRenderer
  def self.call(controller:, community:, messages_count: 0)
    controller.render_to_string(
      partial: "communities/community_card",
      formats: [ :html ],
      locals: { community: community, messages_count: messages_count }
    )
  end
end
