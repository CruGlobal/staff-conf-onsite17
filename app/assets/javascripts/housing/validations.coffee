$ ->
  $('body.housing form').on 'submit', ->
    $form = $(this)
    clean = true
    $form.find('select[name$="[housing_unit_id]"]').each ->
      housing_type =
        $(this).closest('fieldset').find('select[name$="[housing_type]"]').val()
      if $(this).val() == '' && housing_type != 'self_provided'
        alert('All stays must have a housing unit selected')
        clean = false
    $form.find('input[name$="[arrived_at]"]').each ->
      if $(this).val() == ''
        alert('All stays must have an arrival date')
        clean = false
    $form.find('input[name$="[departed_at]"]').each ->
      if $(this).val() == ''
        alert('All stays must have an departure date')
        clean = false

    clean
