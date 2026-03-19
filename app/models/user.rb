class User < ApplicationRecord
  has_many :messages, dependent: :restrict_with_exception
  has_many :reactions, dependent: :restrict_with_exception

  validates :username, presence: true, uniqueness: true
end
