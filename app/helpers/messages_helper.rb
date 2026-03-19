module MessagesHelper
  def sentiment_badge(score)
    return [ "Neutro", "text-bg-secondary" ] if score.nil?

    if score >= 0.2
      [ "Positivo #{score}", "text-bg-success" ]
    elsif score <= -0.2
      [ "Negativo #{score}", "text-bg-danger" ]
    else
      [ "Neutro #{score}", "text-bg-secondary" ]
    end
  end

  def reaction_counts_for(message)
    grouped = message.reactions.group_by(&:reaction_type)
    Reaction::REACTION_TYPES.index_with { |type| grouped[type]&.size.to_i }
  end
end
