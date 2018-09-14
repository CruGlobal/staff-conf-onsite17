pageAction 'user_variables', 'form', ->
  $select = $('select[name="user_variable[value_type]"]')
  $select.on 'change', -> showOnly($(this).val())
  showOnly($select.val())

showOnly = (type) ->
  selected = $("#user_variable_value_#{type}_input")[0]
  console.log selected

  $('.js-value-input').each ->
    $elem = $(this)
    $input = $elem.find('input, select, textarea')

    if this == selected
      $elem.show()
      $input.attr('name', 'user_variable[value]')
    else
      $elem.hide()
      $input.removeAttr('name')
