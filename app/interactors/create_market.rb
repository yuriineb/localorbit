class CreateMarket
  include Interactor

  def perform
    defaults = {
      payment_provider: PaymentProvider.for_new_markets.id,
    }

    market = Market.create(defaults.merge(market_params).merge({:organization_id => context[:organization][:id]}))

    context[:market] = market

    context.fail!(error: "Could not create Market") unless (market.valid? && market.errors.empty?)
  end

  def rollback
     if context_market = context[:market]
        context_market.destroy
    end
  end
end
