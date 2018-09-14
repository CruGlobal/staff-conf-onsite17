# Return the total number of records. Only works on an #index page
window.indexRecordsCount = ->
  count = $('.pagination_information b').last().text() || '0'
  parseInt(count.match(/\d+/)[0], 10)
