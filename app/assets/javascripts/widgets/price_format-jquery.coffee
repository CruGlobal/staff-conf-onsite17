$ ->
  $('[data-money-input]').each (_, elem) -> setupPriceFormat(elem)

  $('body').on 'DOMNodeInserted', (event) ->
    $(event.target).find('[data-money-input]').each (_, elem) ->
      setupPriceFormat(elem)


setupPriceFormat = (elem) ->
  $(elem).priceFormat(
    allowNegative: true,
    limit: 8
  )
