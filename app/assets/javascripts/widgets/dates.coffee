# The number of days ahead of the start date to set the end date
daysIncrement = 1

$ ->
  setupAutomaticEndDates()


# Configures all "start date" inputs, so that when changed, if the associated
# "end date" input is empty, it's value is automatically set to the following
# day.
setupAutomaticEndDates = ->
  $startAt = $('input[name$="[start_at]"]')

  return unless $startAt.length

  $startAt.each ->
    setupSingleStartAtChangeEvent($(this))


# Maps the given "start date" input with the "end date" input field in the same
# form.
# @param {jQuery} $startAt - an input element
setupSingleStartAtChangeEvent = ($startAt) ->
  $form = $startAt.closest('form')
  $endAt = $form.find('input[name$="[end_at]"]')

  return unless $endAt.length

  $startAt.on 'change', ->
    return unless $startAt.val().length

    date = $(this).datepicker('getDate')
    format = $(this).datepicker('option', 'dateFormat')

    unless $endAt.val().length
      newDate = addDays(date, daysIncrement)
      $endAt.val($.datepicker.formatDate(format, newDate))


# @param {Date} date   - the base Date to increment from
# @param {number} days - the number of days to add to the given date
# @return {Date} - a new Date set to the given number of days in advance of the
#   given date
addDays = (date, days) ->
  result = new Date(date)
  result.setDate(result.getDate() + days)
  result
