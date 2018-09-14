pageAction 'families', 'form', ->
  $form = $('form')
  setupHousingTypeDynamicFields($form.find('.housing_preference_attributes'))
  setupConfirmedAtToggleButton($form.find('.housing_preference_attributes'))


# Some fields are only relevant when the user chooses a certain type from the
# Housing Type select box. We hide/show those choices whenever the select's
# value is changed.
setupHousingTypeDynamicFields = ($form) ->
  $select = $form.find('select[name$="[housing_type]"]')
  $select.on 'change', -> showHideDynamicFields($form, $select.val())

  showHideDynamicFields($form, $select.val())


showHideDynamicFields = ($form, housingType) ->
  $form.find('.dynamic-field').hide()
  $form.find(".dynamic-field.for-#{housingType}").show()


# One of the Housing Preference fields is "confirmed_at" the date at which the
# preferences were confirmed by an admin. Here we replace this input field with
# a toggle button that flips this field between null and today's date.
setupConfirmedAtToggleButton = ($form) ->
  $input =
    $form.
      find('input[name="family[housing_preference_attributes][confirmed_at]"]')

  $btn =
    $('<span class="confirmed_at__toggle">').
      on('click', -> toggleConfirmedAtToggleButton($input, $btn))

  $input.css('display', 'none').after($btn)
  updateConfirmedAtToggleButtonLabel($btn, $input.val())


toggleConfirmedAtToggleButton = ($input, $btn) ->
  value = if $input.val().length then '' else new Date().toISOString()
  $input.val(value)
  updateConfirmedAtToggleButtonLabel($btn, value)


updateConfirmedAtToggleButtonLabel = ($btn, value) ->
  if value.length
    $btn.removeClass('no').addClass('yes').text('confirmed!')
  else
    $btn.removeClass('yes').addClass('no').text('unconfirmed')
