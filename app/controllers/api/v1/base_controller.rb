module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      rescue_from ActionController::ParameterMissing do |error|
        render json: { error: error.message }, status: :bad_request
      end

      rescue_from ActiveRecord::RecordNotFound do |error|
        render json: { error: error.message }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |error|
        render json: { error: error.record.errors.full_messages.to_sentence }, status: :unprocessable_content
      end

      rescue_from MessageCreator::ParentCommunityMismatchError do |error|
        render json: { error: error.message }, status: :unprocessable_content
      end

      rescue_from ReactionCreator::MissingUserError do |error|
        render json: { error: error.message }, status: :bad_request
      end

      private

      def required_param!(permitted_params, name)
        value = permitted_params[name]
        raise ActionController::ParameterMissing, name if value.blank?

        value
      end
    end
  end
end
