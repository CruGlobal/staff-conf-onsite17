# Automatically checks/unchecks the Childcare Deposit field if any Childcare
# Weeks are selected, with one exception: if it's checked on page-load, we
# won't uncheck it.
pageAction 'children', 'form', ->
  $checkbox = $('#child_childcare_deposit')
  $selector = $('#child_childcare_weeks')

  checkedOnPageLoad = $checkbox.prop('checked')

  $selector.on 'change', ->
    childcareSelected = !!$(this).val()?.length
    $checkbox.prop('checked', childcareSelected || checkedOnPageLoad)
