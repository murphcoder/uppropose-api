class Api::UsersController < ApplicationController
    before_action :authenticate_user!
  
    def show
      render json: current_user, status: :ok
    end

    def update
      current_user.update(user_params)
    end

    private

    def user_params
      params.require(:user).permit(:work_experience)
    end
end
  