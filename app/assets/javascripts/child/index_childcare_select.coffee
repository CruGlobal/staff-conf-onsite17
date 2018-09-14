CHECK_MARK = '✔'
CROSS_MARK = '✘'

pageAction 'children', 'index', ->
  $('.col-childcare select').each ->
    $(this).on 'change', -> updateChildcareId(this)

# PATCH update the child's +childcare_id+
updateChildcareId = (element) ->
  setAjaxStatus(element, null)

  $select = $(element)
  childcareId = $select.val()
  path = $select.data('path')
  csrf = $('meta[name="csrf-token"]').attr('content')

  $.ajax(
    headers:
      'X-CSRF-Token': csrf
    url: path
    type: 'PATCH'
    dataType: 'json' # the body is ignored anyway
    data:
      child:
        childcare_id: childcareId
  )
    .done -> setAjaxStatus(element, 'good')
    .fail -> setAjaxStatus(element, 'bad')

# Creates a label beside the select element that shows wether the AJAX request
# succeeded.
#
# @param {jQuery} element - the select element to annotate
# @param {string} status- 'good', 'bad', or null (to remove the status element)
setAjaxStatus = (element, status) ->
  $select = $(element)
  $parent = $select.parent()

  $label = $parent.find('.status_tag')
  $label = $('<span class="status_tag">').appendTo($parent) unless $label.length

  $label.removeClass('yes').removeClass('no')

  switch status
    when 'good'
      $label.addClass('ok')
      $label.text(CHECK_MARK)
    when 'bad'
      $label.addClass('error')
      $label.text(CROSS_MARK)
    else
      $label.remove()
