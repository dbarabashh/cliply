module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        def create
          build_resource(sign_up_params)

          if resource.save
            render json: UserSerializer.new(resource).serializable_hash[:data][:attributes], 
                   status: :created
          else
            render json: { errors: resource.errors.full_messages }, 
                   status: :unprocessable_content
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end

        def account_update_params
          params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
        end
      end
    end
  end
end