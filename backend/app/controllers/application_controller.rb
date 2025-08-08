class ApplicationController < ActionController::API
  include ErrorHandler
  
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email password password_confirmation current_password])
  end

  def authenticate_user!
    if request.headers['Authorization'].present?
      begin
        jwt_payload = JWT.decode(
          request.headers['Authorization'].split(' ').last,
          ENV.fetch('JWT_SECRET_KEY', ''),
          true,
          algorithm: 'HS256'
        ).first
        
        @current_user = User.find(jwt_payload['sub'])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'Authorization header missing' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
