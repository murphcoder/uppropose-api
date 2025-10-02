class PaymentsController < ApplicationController
    skip_before_action :authenticate_user, only: [:webhook]

    def webhook
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        endpoint_secret = "whsec_2xxJfQA05LmmSCoBm4Y5N9v3vVFBuorD"

        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

        session = event['data']['object']

        subscription_id = session[:subscription]
        subscription = Stripe::Subscription.retrieve(subscription_id)
        
        unless subscription[:plan][:product] == "prod_T9jAliUqqkCxyE"
            render json: { error: 'Not Authorized' }, status: :unauthorized
        else
            customer_id = session['customer']
            user = User.find_by(stripe_customer_id: customer_id)
            if user
                user.update(date_paid: Date.today)
                user.subscription_length = subscription[:plan][:supscription_period]
            else
                logger.error "User not found for customer ID: #{customer_id}"
            end
        end
    end

    def monthly_url
        monthly_price_id = Rails.env == 'development' ? 'price_1SDPicGsrou80PAeOYz8kSVl' : 'price_1Rsx1ZGsrou80PAeA2cDc3fv'

        monthly_checkout_session = Stripe::Checkout::Session.create({
            payment_method_types: ['card'],
            mode: 'subscription',
            line_items: [
                {
                price: monthly_price_id,
                quantity: 1,
                }
            ],
            customer: current_user.stripe_customer_id,
            success_url: ENV['FRONTEND_URI']
        })

        render json: { url: monthly_checkout_session.url }
    end

    def yearly_url
        yearly_price_id = Rails.env == 'development' ? 'price_1SDPicGsrou80PAevahnimFd' : 'price_1SDLcVGsrou80PAeuo38KdOn'

        yearly_checkout_session = Stripe::Checkout::Session.create({
            payment_method_types: ['card'],
            mode: 'subscription',
            line_items: [
                {
                price: yearly_price_id,
                quantity: 1,
                }
            ],
            customer: current_user.stripe_customer_id,
            success_url: ENV['FRONTEND_URI']
        })

        render json: { url: yearly_checkout_session.url }
    end
end