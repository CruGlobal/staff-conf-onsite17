$ ->
  $('body').on 'DOMNodeInserted', (event) -> setupChosenWidget(event.target)
  setupChosenWidget(document)


setupChosenWidget = (scope) ->
  $('select', scope).each( ->
    $elem = $(this)
    return if $elem.parent().hasClass('ui-datepicker-title')

    hasBlank = allow_single_deselect: $elem.find('option[value=""]').length

    $elem.chosen(
      width: '80%'
      allow_single_deselect: hasBlank
    )
  )
