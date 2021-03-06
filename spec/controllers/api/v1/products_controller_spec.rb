require "spec_helper"

describe Api::V1::ProductsController do
  describe "/index" do
    let(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:seller) { create(:organization, :seller, :single_location, name: 'First Seller') }
    let!(:second_seller) { create(:organization, :seller, :single_location, name: 'Second Seller') }

    let(:market) { create(:market, :with_addresses, organizations: [buyer, seller, second_seller]) }
    let!(:delivery) { create(:delivery_schedule, market: market) }

    let(:market2) { create(:market, :with_addresses, organizations: [buyer, seller, second_seller]) }
    let!(:delivery2) { create(:delivery_schedule, market: market2) }

    # Products
    let!(:pound) { create(:unit, singular: "pound", plural: "pounds") }
    let!(:bananas) { create(:product, name: "Bananas", organization: seller, delivery_schedules: [delivery], unit: pound) }
    let!(:bananas_lot) { create(:lot, product: bananas) }
    let!(:bananas_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer)
    end

    let!(:bananas2) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:bananas2_lot) { create(:lot, product: bananas2) }
    let!(:bananas2_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas2, min_quantity: 1, organization: buyer)
    end

    let!(:crate) { create(:unit, singular: "crate", plural: "crates") }
    let!(:bananas3) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery],
                             unit: crate, general_product: bananas2.general_product) }
    let!(:bananas3_lot) { create(:lot, product: bananas3) }
    let!(:bananas3_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas3, min_quantity: 1, organization: buyer)
    end

    let!(:kale) { create(:product, name: "Kale", organization: seller, delivery_schedules: [delivery]) }
    let!(:kale_lot) { create(:lot, product: kale) }
    let!(:kale_price_buyer_base) do
      create(:price, :past_price, market: market, product: kale, min_quantity: 1)
      create(:price, :past_price, market: market, product: kale, min_quantity: 10, sale_price: 1.75)
    end

    let!(:promotion) { create(:promotion, :active, product: bananas, market: market, body: "Big savings!") }

    let!(:cart) { create(:cart, market: market, organization: buyer, user: user, delivery: delivery.next_delivery) }

    # products without inventory should not appear in search results
    let!(:beans) { create(:product, name: "Beans", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:beans_lot) { create(:lot, product: beans, quantity: 0) }
    let!(:beans_price_buyer_base) do
      create(:price, :past_price, market: market, product: beans, min_quantity: 1, organization: buyer)
    end

    # products for another market should not appear in search results
    let!(:peanuts) { create(:product, name: "Peanuts", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:peanuts_lot) { create(:lot, product: peanuts) }
    let!(:peanuts_price_buyer_base) do
      create(:price, :past_price, market: market2, product: peanuts, min_quantity: 1, organization: buyer)
    end

    before do
      switch_to_subdomain market.subdomain
      sign_in user
      session[:cart_id] = Cart.first.id
    end

    def get_products(params)
      get :index, params
      products = JSON.parse(response.body)["products"]
      products.map { |general_product| general_product["available"].map { |product| product["id"] } }
    end

    it "returns a paginated list of products" do
      products = get_products({ })
      expected_products = [[bananas.id], [bananas3.id, bananas2.id], [kale.id]]
      expect(products).to eq(expected_products)
      products = get_products(offset: 0)
      expect(products).to eq(expected_products)

      products = get_products(offset: 2)
      expect(products).to eq(expected_products.slice(2,1))

      products = get_products(offset: 1)
      expect(products).to eq(expected_products.slice(1,2))
    end

    it "searches by text" do
      products = get_products(offset: 0, query: "kale")
      expect(products).to eq([[kale.id]])
      products = get_products(offset: 0, query: "xxxx")
      expect(products).to eq([])
      products = get_products(offset: 0, query: "Apple")
      expect(products).to eq([[bananas.id], [bananas3.id, bananas2.id], [kale.id]])
      products = get_products(offset: 1, query: "Apple")
      expect(products).to eq([[bananas3.id, bananas2.id], [kale.id]])
      products = get_products(offset: 0, query: "First")
      expect(products).to eq([[bananas.id], [kale.id]])
      products = get_products(offset: 0, query: "second")
      expect(products).to eq([[bananas3.id, bananas2.id]])
    end

    it "filters results by seller" do
      products = get_products(offset: 0, query: "banana", seller_ids: [])
      expect(products).to eq ([[bananas.id], [bananas3.id, bananas2.id]])
      products = get_products(offset: 0, query: "banana", seller_ids: [bananas.organization_id])
      expect(products).to eq ([[bananas.id]])
      products = get_products(offset: 0, query: "banana", seller_ids: [bananas2.organization_id])
      expect(products).to eq ([[bananas3.id, bananas2.id]])
      products = get_products(offset: 0, query: "banana", seller_ids: [bananas.organization_id, bananas2.organization_id])
      expect(products).to eq ([[bananas.id], [bananas3.id, bananas2.id]])
    end

    it "filters results by category and seller" do
      products = get_products(offset: 0, query: "Apple", category_ids: [-1, -2])
      expect(products).to eq ([])
      products = get_products(offset: 0, query: "Apple", seller_ids: [-1])
      expect(products).to eq ([])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.category_id])
      expect(products).to eq ([[kale.id]])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.top_level_category_id])
      expect(products).to eq ([[kale.id]])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.second_level_category_id])
      expect(products).to eq ([[kale.id]])
    end

    it "removes products when soft deleted" do
      products = get_products(offset: 0, query: "kale", category_ids: [kale.category_id])
      expect(products).to eq ([[kale.id]])

      kale.soft_delete

      products = get_products(offset: 0, query: "kale", category_ids: [kale.category_id])
      expect(products).to eq ([])
    end
  end
end
