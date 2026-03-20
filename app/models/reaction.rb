class Reaction < ApplicationRecord
  REACTION_TYPES = %w[like love insightful].freeze

  belongs_to :message
  belongs_to :user

  validates :reaction_type, presence: true, inclusion: { in: REACTION_TYPES }
  validates :reaction_type, uniqueness: { scope: [ :message_id, :user_id ] }
end
