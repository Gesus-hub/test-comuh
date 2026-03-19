module Api
  module V1
    class AnalyticsController < BaseController
      def suspicious_ips
        render json: {
          suspicious_ips: SuspiciousIpsQuery.new(min_users: params[:min_users]).call
        }
      end
    end
  end
end
