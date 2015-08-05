class ProductsController < ApplicationController
  before_action :before_actions, only: [:index, :show]
  skip_before_action :set_intercom_attributes, :masquerade_user!, only: [:search]

  def before_actions
    require_selected_market
    require_market_open
    require_current_organization
    require_organization_location
    require_current_delivery
    require_cart
    hide_admin_navigation
    load_products
  end

  def index
    if current_market.alternative_order_page
      render 'alternative_order_page'
    else
      render 'index'
    end
  end

  def show
    @product = @products_for_sale.products.first || raise(ActiveRecord::RecordNotFound)

    @breadcrumbs = [@product.category]
    while @breadcrumbs.last.parent_id.present?
      @breadcrumbs.push @breadcrumbs.last.parent
    end
    @breadcrumbs.pop
    @breadcrumbs.reverse!
  end

  def search
    search = params[:q]
    @sellers ||= current_market.organizations.where(can_sell: true, active: true).pluck(:id)
    matching_and_available_products = current_delivery.object.delivery_schedule.products.search_by_text(search).where(organization_id: @sellers).limit(50)

    render :json => matching_and_available_products.map {|p| {:id=>p.id, :name=>p.name} }
  end

  def render_product_row
    product = Product.find(params[:product_id])
    if product
      render :json => {
        html: render_to_string("_table_row", :locals => {
          product: product.decorate(context: {current_cart: current_cart})
        }, :layout => false)
      }
    end
  end

  private

  def load_products
    @products_for_sale = ProductsForSale.new(current_delivery, current_organization, current_cart, request.query_parameters, product_id: params[:id])
  end
end
