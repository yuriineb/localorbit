class Admin::OrderSummariesController < AdminController
  def show
    #@delivery = Delivery.find(params[:id]).decorate
    dt = params[:deliver_on].to_date
    dte = dt.strftime("%Y-%m-%d")

    if params[:market_id].nil?
      market_id = current_market.id
    else
      market_id = params[:market_id]
    end

    #market_id = Market.managed_by(current_user).pluck(:id)

    order_items = OrderItem.for_delivery_date_and_user(dte, current_user, market_id)
    @summaries = OrdersBySellerPresenter.new(order_items)
    #@delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
    @delivery_notes = DeliveryNote.joins(:order).where(order: order_items.map(&:order_id))

  end
end
