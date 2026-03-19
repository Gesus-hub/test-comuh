class SuspiciousIpsQuery
  DEFAULT_MIN_USERS = 3

  def initialize(min_users: nil)
    @min_users = min_users
  end

  def call
    Message
      .joins(:user)
      .group(:user_ip)
      .having("COUNT(DISTINCT messages.user_id) >= ?", normalized_min_users)
      .pluck(
        Arel.sql("messages.user_ip"),
        Arel.sql("COUNT(DISTINCT messages.user_id)"),
        Arel.sql("ARRAY_AGG(DISTINCT users.username ORDER BY users.username)")
      )
      .map do |ip, user_count, usernames|
        SuspiciousIpSerializer.new(
          ip: ip,
          user_count: user_count,
          usernames: usernames
        ).as_json
      end
  end

  private

  def normalized_min_users
    raw = @min_users.to_i
    return DEFAULT_MIN_USERS if raw <= 0

    raw
  end
end
