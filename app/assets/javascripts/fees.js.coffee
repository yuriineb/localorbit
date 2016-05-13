$ ->
  formatFieldAsMoney = (field) ->
    field.val(parseFloat(field.val()).toFixed(2))

  bindCalculator = (el) ->
    salePrice = $(el)
    fee = salePrice.parent().parent().parent().first().find('input.market-seller-fee')
    markup_pct = salePrice.parent().parent().first().find('div.markup-pct')
    netPrice = salePrice.parent().parent().first().find('input.net-price')
    ccRate = .029

    getNetPriceValue = ->
      parseFloat(netPrice.val())

    setNetPriceValue = (v) ->
      if v > 0
        netPrice.val(v.toFixed(2))
      else
        netPrice.val('')

    getFeeValue = ->
      parseFloat(fee.val())

    setFeeValue = (v) ->
      if v > 0
        fee.val(v.toFixed(2))
      else
        fee.val('')

    setMarkupValue = (v) ->
      if v > 0
        markup_pct.html(v.toFixed(2))
      else
        markup_pct.html('')

    getSalePriceValue = ->
      parseFloat(salePrice.val())

    setSalePriceValue = (v) ->
      if v > 0
        salePrice.val(v.toFixed(2))
      else
        salePrice.val('')

    getNetPercent = ->
      if getFeeValue() > 0
          return 1 - (getFeeValue()/100 + ccRate)

    updateMarkupPct= ->
      netPriceValue = getNetPriceValue()
      salePriceValue = getSalePriceValue()
      feeValue = ((salePriceValue - netPriceValue) / netPriceValue) * 100
      setMarkupValue(feeValue)

    updateFee = ->
      netPriceValue = getNetPriceValue()
      salePriceValue = getSalePriceValue()
      feeValue = (1-netPriceValue/salePriceValue)*100
      setFeeValue(feeValue)

    updateNetPrice = ->
      salePriceValue = getSalePriceValue()
      netPercent = getNetPercent()
      netPriceValue = salePriceValue * netPercent
      setNetPriceValue(netPriceValue)

    updateSalePrice = ->
      y = getNetPriceValue() / getNetPercent()
      setSalePriceValue(y)

    salePrice.change ->
      updateNetPrice()
      updateMarkupPct()

    salePrice.on 'keyup', ->
      $(this).trigger('change')

    salePrice.on 'blur', ->
      if ($(this).val() > 0)
        formatFieldAsMoney($(this))

    salePrice.trigger('blur')

    fee.change ->
      updateSalePrice()
      updateMarkupPct()

    fee.on 'keyup', ->
      $(this).trigger('change')

    fee.trigger('blur')

    netPrice.change ->
      updateSalePrice()
      updateMarkupPct()

    netPrice.on 'keyup', ->
      $(this).trigger('change')

    netPrice.on 'blur', ->
      if ($(this).val() > 0)
        formatFieldAsMoney($(this))

    netPrice.trigger('blur')

  $('input.sale-price').each ->
    bindCalculator(this)
