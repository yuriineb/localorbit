module Sessions
  class DeliveriesController < ApplicationController
    before_action :require_selected_market
    before_action :require_current_organization
    before_action :require_organization_location
    before_action :require_manual_delivery_schedule, only: [:create]
    before_action :hide_admin_navigation

    def new
      current_organization.carts.find_by(id: session[:cart_id]).try(:destroy)

      if current_market.is_buysell_market?
        @deliveries = current_market.delivery_schedules.includes(:buyer_pickup_location).delivery_visible.
                      map {|ds| ds.next_delivery.decorate(context: {current_organization: current_organization}) }.
                      sort_by {|d| d.buyer_deliver_on }
      end
    end

    def create
      if current_market.is_consignment_market?
        delivery_schedule = current_market.delivery_schedules.manual.first
        delivery = delivery_schedule.deliveries.create!(
            deliver_on: params[:buyer_deliver_on],
            buyer_deliver_on: params[:buyer_deliver_on],
            cutoff_time: params[:buyer_deliver_on].to_date - delivery_schedule.order_cutoff.hours
        )
        session[:current_delivery_id] = delivery.id
      else
        session[:current_delivery_day] = params[:delivery_day]
        session[:current_delivery_id] = params[:delivery_id].to_i
        return invalid_delivery_selection if current_delivery.nil?

        if current_delivery.requires_location?
          session[:current_location] = params[:location_id].try(:[], params[:delivery_id])

          # This will sort out if the selected location is valid
          # of if there is a valid selection that could be made
          if (location = selected_organization_location)
            session[:current_location] = location.id
          else
            return invalid_delivery_selection
          end
        end
      end
      redirect_to redirect_to_url
    end

    def reset
      session.delete(:current_delivery_id)
      session.delete(:current_organization_id)

      redirect_to new_sessions_deliveries_path(redirect_back_to: redirect_to_url)
    end

    protected

    def invalid_delivery_selection
      flash.now[:alert] = 'Please select a delivery'
      new
      render :new
    end
  end
end
