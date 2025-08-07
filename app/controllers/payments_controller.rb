class PaymentsController < ApplicationController
    skip_before_action :authenticate_user

    def webhook
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        endpoint_secret = "whsec_38513f46d94615c08a480a7822ad720f02ef598e109c08873c1b2eedaa46bbfd"

        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

        session = event['data']['object']
        
        unless session[:product] == "prod_Sobj1tewng9TXF"
            render json: { error: 'Not Authorized' }, status: :unauthorized
        else
            customer_id = session['customer']
            user = User.find_by(stripe_customer_id: customer_id)
            if user
                user.update(date_paid: Date.today)  # Or any other relevant update
            else
                # Handle the case where no user is found for this customer_id
                logger.error "User not found for customer ID: #{customer_id}"
            end
        end
    end
end