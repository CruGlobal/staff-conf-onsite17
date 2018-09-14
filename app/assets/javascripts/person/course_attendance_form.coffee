containerSelector = '.has_many_container.course_attendances'
itemSelector = '.inputs.has_many_fields'

$ ->
  setupCourseAttendanceForm()


setupCourseAttendanceForm = ->
  $form = $('#new_attendee, #edit_attendee')
  return unless $form.length


  $('body').on 'DOMNodeInserted', (event) ->
    if $(event.target).is("#{containerSelector} #{itemSelector}")
      $(event.target).find('select').chosen(width: '80%')
