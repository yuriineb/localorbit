require "spec_helper"

describe CartsController do
  let!(:market)   { create(:market, :with_address, :with_delivery_schedule) }
  let!(:delivery) { market.delivery_schedules.first.next_delivery }
  let!(:seller)   { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product)  { create(:product, :sellable, organization: seller) }

  let!(:buyer)    { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:user)     { create(:user, :buyer, organizations: [buyer]) }

  let!(:cart)     { create(:cart, market: market, organization: buyer, delivery: delivery, location: buyer.locations.first, user: user) }

  describe "#update" do
    it "does not error when 0 is entered for a new item" do
      sign_in(user)
      switch_to_subdomain(market.subdomain)

      params = {
        format: "json",
        product_id: product.id,
        quantity: 0
      }

      request.accept = "application/json"
      put :update, params

      expect(response).to be_success
      expect(cart.reload.items.count).to eql(0)
    end

    it "adds a new item" do
      sign_in(user)
      switch_to_subdomain(market.subdomain)

      params = {
        format: "json",
        product_id: product.id,
        quantity: 1
      }

      request.accept = "application/json"
      put :update, params

      expect(response).to be_success
      expect(cart.reload.items.count).to eql(1)
    end
  end

  describe "#show" do
    before do
      sign_in(user)
      switch_to_subdomain(market.subdomain)
    end

    it "returns the total count for a cart if .json is requested" do
      get :show, {format: "json"}
      data = JSON.parse(response.body)
      expect(data["total"]).to eq 0
    end

    it "returns accurate counts for multiple items" do
      create_list(:cart_item, 2, cart: cart)
      get :show, {format: "json"}
      data = JSON.parse(response.body)
      expect(data["total"]).to eq 2
    end

    it "does not count quantity" do
      cart_item = create(:cart_item, cart: cart)
      create(:cart_item, cart: cart)
      cart_item.quantity = 2
      cart_item.save
      get :show, {format: "json"}
      data = JSON.parse(response.body)
      expect(data["total"]).to eq 2
    end

    it "sets the payment provider" do
      market.update payment_provider: 'the provider' 
      get :show
      expect(assigns[:payment_provider]).to eq('the provider')
    end
  end
end
