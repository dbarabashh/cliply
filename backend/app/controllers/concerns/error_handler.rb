module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :bad_request
    end

    rescue_from JWT::DecodeError do |e|
      render json: { error: 'Invalid token' }, status: :unauthorized
    end

    rescue_from JWT::ExpiredSignature do |e|
      render json: { error: 'Token has expired' }, status: :unauthorized
    end
  end
end