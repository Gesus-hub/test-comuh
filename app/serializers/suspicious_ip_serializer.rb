class SuspiciousIpSerializer
  def initialize(ip:, user_count:, usernames:)
    @ip = ip
    @user_count = user_count
    @usernames = usernames
  end

  def as_json(*)
    {
      ip: @ip,
      user_count: @user_count.to_i,
      usernames: @usernames
    }
  end
end
