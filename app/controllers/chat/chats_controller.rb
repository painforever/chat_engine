module Chat
  class ChatsController < ApplicationController
    before_action :set_patient, only: [:index, :show, :edit]
    before_action :set_message, only: [:create, :new, :index]

    def index
      if current_user.patient?
        @provider_accesses = @patient.provider_accesses.with_providers_primary_taxonomies
        @user_ids = Provider.where(id: @provider_accesses.pluck(:provider_id)).pluck(:user_id)
        if params[:access_id].present?
          @provider_access = ProviderAccess.find(params[:access_id])
          @messages = ChatMessage.with_sender.where(provider_access_id: params[:access_id])
        else
          @provider_access = ProviderAccess.find(@provider_accesses.first.id)
          @messages = ChatMessage.with_sender.where(provider_access_id: @provider_accesses.first.id)
        end
      elsif current_user.provider?
        set_provider
        @provider_accesses = @provider.provider_accesses.with_providers_primary_taxonomies
        @user_ids = Patient.where(id: @provider_accesses.pluck(:patient_id)).pluck(:user_id)
        if params[:access_id].present?
          @provider_access = ProviderAccess.find(params[:access_id])
          @messages = ChatMessage.with_sender.where(provider_access_id: params[:access_id])
        else
          @provider_access = ProviderAccess.find(@provider_accesses.first.id)
          @messages = ChatMessage.with_sender.where(provider_access_id: @provider_accesses.first.id)
        end
      end
    end

    def create
      @chat_message = ChatMessage.new(ChatMessage.params(params))
      @chat_message.save!
    end


    

    def pay
      Stripe.api_key = Constants::STRIPE_API_SECRET_KEY

      # Get the credit card details submitted by the form
      token = params[:stripeToken]

      # Create a charge: this will charge the user's card
      begin
        #Keep this as a sample of basic Stripe payment
        # charge = Stripe::Charge.create(
        #     :amount => 500, # Amount in cents
        #     :currency => "usd",
        #     :source => token,
        #     :description => "Example charge",
        #     :metadata => {"order_id" => "6735"}
        # )

        #If the current_user has no stripe_customer_id in the DB, that means this is the first time he provide
        #their bank account info, so let's create a Stripe Customer on the cloud to store their bank info for
        #use it later.
        if current_user.stripe_customer_id.blank?
          customer = Stripe::Customer.create(
              card: token,
              description: "#{current_user.email}-#{current_user.display_name}",
              email: current_user.email
          )
          customer_id = customer.id
        else
          customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
          customer_id = current_user.stripe_customer_id
        end
        # Stripe::Charge.create(
        #     amount: cart_total_price, # $15.00 this time
        #     currency: 'usd',
        #     customer: customer_id
        # )

        #TODO I know this is ugly but it can define less functions, we can optimize this later
        @card = {card_number: ("*****#{params[:card_number][-4..-1]}" rescue nil) || "*****#{customer[:sources][:data].first[:last4]}",
                 cvv: params[:cvv] || "",
                 exp_date: "#{params[:exp_year] || customer[:sources][:data].first[:exp_year]}-
                 #{params[:exp_month] || customer[:sources][:data].first[:exp_month]}",
                 card_holder_name: params[:card_holder_name] || ""}
        PaymentMailer.payment_success(current_user, @card).deliver_now
        PaymentMailer.send_essay(current_user, session[:cart]).deliver_now
        session[:cart] = nil
        # save the customer ID in your database so you can use it later
        current_user.update_column("stripe_customer_id", customer_id)
      rescue Stripe::CardError => e
        @transaction_falied = true
        # The card has been declined
        PaymentMailer.payment_failed(current_user, @card).deliver_now
      end
      render 'payment_confirmation'
    end

    def config_cc
      if params[:stripeToken]
        token = params[:stripeToken]
        @knockee = User.find(params[:knockee_id])
        customer = Stripe::Customer.create(
            card: token,
            description: "#{current_user.email}-#{current_user.display_name}",
            email: current_user.email
        )
        current_user.update_column("stripe_customer_id", customer.id)
        flash[:card_setup] = "Your card has been setup successfully, continue and happy knocking."
        redirect_to users_path
      elsif params[:back]
        redirect_back fallback_location: users_path
      end
      #render json: "success", status: :ok
    end

    private
    def set_message
      @chat_message = ChatMessage.new
    end

    def set_provider
      @provider = Provider.find(params[:provider_id])
    end
  end
end
