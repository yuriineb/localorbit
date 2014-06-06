require 'spec_helper'

describe "Managing featured promotions" do
  let!(:market)  { create(:market) }
  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:active_promotion) { create(:promotion, :active, market: market, product: product, name: 'Active Promotion') }
  let!(:promotion) { create(:promotion, market: market, product: product, name: 'Unactive Promotion') }

  context "as a market manager" do
    let!(:user) { create(:user, managed_markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as user

      visit admin_promotions_path
    end

    context "list view" do
      it "shows a list of the featured promotions for the market" do
        expect(page).to have_content("Featured Promotions")

        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(2)
        expect(promotions.map(&:name)).to include(active_promotion.name, promotion.name)
      end
    end

    context "create a promotion" do
      it "accepts valid input" do
        click_link "Add New Promotion"

        fill_in "Name", with: "Summer Promotion"
        select market.name, from: "Market"
        fill_in "Title", with: "Summer Promotion: Apples"
        select product.name, from: "Product"

        click_button "Save Promotion"

        expect(page).to have_content("Successfully created the featured promotion.")

        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(3)
        expect(promotions.map(&:name)).to include(active_promotion.name, promotion.name, "Summer Promotion")
      end

      it "displays errors for invalid input" do
        click_link "Add New Promotion"

        fill_in "Name", with: ""
        select market.name, from: "Market"
        fill_in "Title", with: "Summer Promotion: Apples"
        select product.name, from: "Product"

        click_button "Save Promotion"

        expect(page).to_not have_content("Successfully created the featured promotion.")
        expect(page).to have_content("Name can't be blank")
      end
    end

    context "update a promotion" do
      it "accepts valid input" do
        click_link active_promotion.name

        fill_in "Name", with: "Changed Promotion"

        click_button "Save Promotion"

        expect(page).to have_content("Successfully updated the featured promotion.")

        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(2)
        expect(promotions.map(&:name)).to include("Changed Promotion")
      end

      it "displays errors for invalid input" do
        click_link active_promotion.name

        fill_in "Name", with: ""

        click_button "Save Promotion"

        expect(page).to_not have_content("Successfully updated the featured promotion.")
        expect(page).to have_content("Name can't be blank")
      end
    end

    context "remove a promotion" do
      it "is successful" do
        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(2)

        Dom::Admin::FeaturedPromotionRow.find_by_name(promotion.name).click_delete

        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(1)
        expect(promotions.map(&:name)).to include(active_promotion.name)
      end
    end
  end

end
