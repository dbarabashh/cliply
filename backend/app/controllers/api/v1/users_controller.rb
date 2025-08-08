module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user!, only: []

      def me
        render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      end

      def show
        user = User.find(params[:id])
        render json: UserSerializer.new(user).serializable_hash[:data][:attributes]
      end

      def update
        if current_user.update(user_params)
          render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
        else
          render json: { errors: current_user.errors.full_messages }, 
                 status: :unprocessable_content
        end
      end

      private

      def user_params
        params.require(:user).permit(:email)
      end
    end
  end
end