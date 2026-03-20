class CommunitySerializer
  def initialize(community, html: nil)
    @community = community
    @html = html
  end

  def as_json(*)
    {
      id: @community.id,
      name: @community.name,
      description: @community.description,
      html: @html
    }.compact
  end
end
