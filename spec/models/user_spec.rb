require 'spec_helper'

describe User do
  describe 'roles' do

    describe "#can_manage_organization?" do
      let(:org) { create(:organization) }

      context "when user is an admin" do
        let(:user) { create(:user, role: 'admin') }

        it "returns true" do
          expect(user.can_manage_organization?(org)).to be true
        end
      end

      context "when the user is a market manager" do
        let(:market_manager) { create(:user, :market_manager) }
        let(:market) { market_manager.managed_markets.first }

        context "and the org is in their managed market" do
          before do
            market.organizations << org
          end

          it "returns true" do
            expect(market_manager.can_manage_organization?(org)).to be true
          end
        end

        context "and the org is not in their managed market" do
          it "returns false" do
            expect(market_manager.can_manage_organization?(org)).to be false
          end
        end
      end

      context "user does not manage any market" do
        let(:user) { create(:user, role: 'user') }

        it "returns false" do
          expect(user.can_manage_organization?(org)).to be false
        end
      end
    end

    it 'admin? returns true if role is "admin"' do
      user = build(:user)
      user.role = 'admin'
      expect(user.admin?).to be true
    end

    it 'admin? returns false if role is not "admin"' do
      user = build(:user)
      user.role = 'user'
      expect(user.admin?).to be false

      user.role = 'manager'
      expect(user.admin?).to be false

      user.role = 'something else'
      expect(user.admin?).to be false
    end
  end

  describe 'managed_organizations' do

    context 'for an admin' do
      let(:user) { create(:user, :admin) }

      it 'returns a scope with all organizations' do
        expect(user.managed_organizations).to eq(Organization.all)
      end
    end

    context 'for a market manager' do
      let(:user) { create(:user, :market_manager) }
      let(:market1) { user.managed_markets.first }
      let(:market2) { user.managed_markets.create!(attributes_for(:market)) }
      let(:market3) { create(:market) }

      let(:org1) { create(:organization, name: 'Org 1') }
      let(:org2) { create(:organization, name: 'Org 2') }
      let(:org3) { create(:organization, name: 'Org 3') }
      let(:org4) { create(:organization, name: 'Org 4') }
      let(:org5) { create(:organization, name: 'Org 5') }

      before do
        market1.organizations << org1
        market1.organizations << org5
        market2.organizations << org2
        market3.organizations << org3
        market3.organizations << org4
        user.organizations << org4
        user.organizations << org5
      end

      it 'returns a chainable scope' do
        expect(user.managed_organizations).to be_a_kind_of(ActiveRecord::Relation)
      end

      it "includes organizations in their managed markets" do
        expect(user.managed_organizations).to include(org1, org2)
      end

      it "includes organizations they directly belong to" do
        expect(user.managed_organizations).to include(org4, org5)
      end

      it "does not include organizations in other markets" do
        expect(user.managed_organizations).to_not include(org3)
      end
    end

    context 'for a user' do
      let(:user) { create(:user, role: 'user') }

      it 'returns a scope for the organization memberships' do
        expect(user.managed_organizations).to eq(user.organizations)
      end
    end
  end

  describe 'markets' do
    context 'admin' do
      let(:user) { create(:user, :admin) }

      it 'returns all markets' do
        expect(user.markets).to eq(Market.all)
      end
    end

    context 'market manager' do
      let(:user) { create(:user, :market_manager) }
      let(:market1) { user.managed_markets.first }
      let(:market2) { create(:market) }
      let(:market3) { create(:market) }
      let(:org) { create(:organization) }

      before(:each) do
        user.organizations << org
        market2.organizations << org
      end

      it 'returns a relation object' do
        expect(user.markets).to be_kind_of(ActiveRecord::Relation)
      end

      it 'belongs to the markets they manage' do
        expect(user.markets).to include(market1)
      end

      it 'belongs to markets their organizations belong to' do
        expect(user.markets).to include(market2)
      end

      it 'does not show markets for which they are not members' do
        expect(user.markets).to_not include(market3)
      end
    end

    context 'user' do
      let(:user) { create(:user, role: 'user') }
      let(:market1) { create(:market) }
      let(:market2) { create(:market) }
      let(:org) { create(:organization) }

      before(:each) do
        user.organizations << org
        market1.organizations << org
      end

      it 'returns a relation object' do
        expect(user.markets).to be_kind_of(ActiveRecord::Relation)
      end

      it 'belongs to markets their organizations belong to' do
        expect(user.markets).to include(market1)
      end

      it 'does not show markets for which they are not members' do
        expect(user.markets).to_not include(market2)
      end
    end
  end

  describe 'managed_products' do
    subject { user.managed_products }

    context 'for an admin' do
      let(:user) { create(:user, :admin) }

      it 'returns all products' do
        expect(subject).to eq(Product.all)
      end
    end

    context 'for a market manager' do
      let(:user) { create(:user, :market_manager) }
      let(:market1) { user.managed_markets.first }
      let(:market2) { create(:market) }
      let(:org1) { create(:organization) }
      let(:org2) { create(:organization) }
      let(:prod1) { create(:product, organization: org1) }
      let(:prod2) { create(:product, organization: org2) }

      before do
        market1.organizations << org1
        market2.organizations << org2
      end

      it "returns a scope" do
        expect(subject).to be_kind_of(ActiveRecord::Relation)
      end

      it "returned scope includes products for organizations in markets they manage" do
        expect(subject).to include(prod1)
      end

      it "returned scope does not include products for organizations in markets they do not manage" do
        expect(subject).to_not include(prod2)
      end
    end

    context 'for a user' do
      let(:user) { create(:user) }
      let(:market1) { create(:market) }
      let(:org1) { create(:organization) }
      let(:org2) { create(:organization) }
      let(:prod1) { create(:product, organization: org1) }
      let(:prod2) { create(:product, organization: org2) }

      before do
        market1.organizations << org1
        market1.organizations << org2
        org1.users << user
      end

      it "returns a scope" do
        expect(subject).to be_kind_of(ActiveRecord::Relation)
      end

      it "returned scope includes products for organizations they belong to" do
        expect(subject).to include(prod1)
      end

      it "returned scope does not include products for organization they do not belong to" do
        expect(subject).to_not include(prod2)
      end

    end
  end
end
