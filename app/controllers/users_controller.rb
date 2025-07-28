class Api::UsersController < ApplicationController
    before_action :authenticate_user!
  
    # GET /me
    def me
      render json: current_user, status: :ok
    end
  
    # GET /users/:id/proposals
    def proposals
      user = User.find(params[:id])
      if user == current_user
        render json: user.proposals, status: :ok
      else
        render json: { error: "Access denied" }, status: :unauthorized
      end
    end
end
  