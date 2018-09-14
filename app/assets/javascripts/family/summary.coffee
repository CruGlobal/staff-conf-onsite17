$ ->
  $('.summary span.title').each ->
    span = $(this)
    if span.data('type') == 'Child'
      url = '/children/'
    else
      url = '/attendees/'
    url += span.data('id') + '/edit'
    link = '<a href="' + url + '">' + span.html() + '</a>'
    span.replaceWith(link)

  $('.summary.families form').on 'submit', ->
    button = $('#checkin_button input', this)
    button.replaceWith('Processing...')