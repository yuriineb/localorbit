require "spec_helper"

feature "Viewing admin/organizations list" do
  let!(:market1) { create(:market, managers: [market_manager]) }
  let!(:market2) { create(:market) }

  let!(:org1) { create(:organization, markets: [market1]) }
  let!(:org2) { create(:organization, markets: [market1]) }
  let!(:org3) { create(:organization, markets: [market1]) }
  let!(:org4) { create(:organization, markets: [market2]) }

  let!(:user) { create(:user, organizations: [org1, org2]) }
  let!(:market_manager) { create(:user) }

  context "as an organization member", :suspend_user do
    before do
      u = user.user_organizations.find_by(organization: org2)
      u.update_attributes(enabled: false)

      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit organizations_path
    end

    scenario "I can see a list of organizations I belong to" do
      expect(page).to have_link(org1.name)
      expect(page).not_to have_link(org3.name)
    end

    scenario "I cannot click to edit an organization I've been suspended from" do
      expect(page).to have_content(org2.name)
      expect(page).not_to have_link(org2.name)
    end
  end

  context "as a market manager" do
    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(market_manager)
      visit admin_organizations_path
    end

    scenario "I can click to edit any organization in my market" do
      expect(page).to have_content(org1.name)
      expect(page).to have_content(org2.name)
      expect(page).to have_content(org3.name)
    end
  end
end
