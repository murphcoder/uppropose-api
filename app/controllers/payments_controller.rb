class PaymentsController < ApplicationController
    skip_before_action :authenticate_user
    before_action :authenticate_gumroad

    def gumroad_webhook
        User.find_by(email: params[:email]).update(date_paid: Date.today) if params[:product_id] == "6H7lEFl0uC2uKW40KWfL-w=="
    end

    def authenticate_gumroad
        render json: { error: "Access forbidden" }, status: :forbidden unless params[:seller_id] == "n1PdC2n8pZdYJdDkxsCY6w=="
    end
end