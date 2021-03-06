module Admin
  class DeliverySchedulesController < AdminController
    before_action :require_admin_or_market_manager
    before_action :find_market

    def index
      @delivery_schedules = @market.delivery_schedules.where("deleted_at is null or is_recoverable='t'").order(:day)
    end

    def new
      @delivery_schedule = @market.delivery_schedules.build
    end

    def create
      @delivery_schedule = @market.delivery_schedules.build(delivery_schedule_params)
      if @delivery_schedule.save
        AddDeliveryScheduleToProducts.perform(delivery_schedule: @delivery_schedule, market: @market)

        redirect_to [:admin, @market, :delivery_schedules], notice: "Saved delivery schedule."
      else
        render :new
      end
    end

    def edit
      @delivery_schedule = @market.delivery_schedules.find(params[:id])
      render :new
    end

    def update
      @delivery_schedule = @market.delivery_schedules.find(params[:id])
      p = delivery_schedule_params
      if params[:delivery_schedule][:day_of_month].nil?
        p = p.merge(:day_of_month => "")
      end
      if params[:delivery_schedule][:delivery_cycle] == "weekly"
        p = p.merge(:week_interval => "1")
      end

      if params[:delivery_schedule][:delivery_cycle] != "manual"
        interactor = UpdateDeliveryScheduleAndCurrentDelivery.perform(params: p,
                                                                      delivery_schedule: @delivery_schedule)
        if interactor.success?
          redirect_to [:admin, @market, :delivery_schedules], notice: "Saved delivery schedule."
        else
          render :new
        end
      else
        redirect_to [:admin, @market, :delivery_schedules], notice: "Saved delivery schedule."
      end
    end

    def update_active
      @delivery_schedule = @market.delivery_schedules.find(params[:id])
      message = nil

      if params[:active] == "false"
        if @delivery_schedule.update_attributes(is_recoverable: true, inactive_at: Time.current)
          message = "Deactivated delivery schedule."
        end
      else
        if @delivery_schedule.update_attributes(is_recoverable: true, inactive_at: nil)
          message = "Activated delivery schedule."
        end
      end

      redirect_to [:admin, @market, :delivery_schedules], notice: message
    end

    def destroy
      @delivery_schedule = @market.delivery_schedules.find(params[:id])
      @delivery_schedule.update_attributes(is_recoverable: false, deleted_at: Time.current)
      redirect_to [:admin, @market, :delivery_schedules], notice: "Deleted delivery schedule."
    end

    private

    def delivery_schedule_params
      params.require(:delivery_schedule).permit(
        :delivery_cycle,
        :week_interval,
        :day_of_month,
        :day,
        :buyer_day,
        :fee,
        :fee_label,
        :fee_type,
        :order_cutoff,
        :require_delivery,
        :require_cross_sell_delivery,
        :order_minimum,
        :seller_fulfillment_location_id,
        :seller_delivery_start,
        :seller_delivery_end,
        :buyer_pickup_location_id,
        :buyer_pickup_start,
        :buyer_pickup_end,
        :market_pickup
      )
    end
  end
end
