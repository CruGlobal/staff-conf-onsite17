LIMITS = [10, 30, 50, 100, 200, 500, 1000, 5000, 10000, 100000]

# Creates a dropdown selector which allows the user to refresh the page,
# selecting how many records to display on each page
pageAction 'index', ->
  $('.table_tools').append(perPageDropdown())

perPageDropdown = ->
  $list = $('<ul class="dropdown_menu_list">')
  $list.append($item) for $item in perPageDropdownItems()

  title = "Records Per Page (#{currentPerPage()})"

  $('<div class="dropdown_menu">').append(
    $('<a class="dropdown_menu_button" href="#">').text(title),
    $('<div class="dropdown_menu_list_wrapper">').css('display', 'none').append(
      $list
    )
  )

perPageDropdownItems = ->
  items = (createItem(limit, limit) for limit in applicableLimits())
  $lastLink = items[items.length - 1].children()
  $lastLink.text("All #{$lastLink.text()}")
  items

# Returns a subset of LIMITS containing only those numbers less than the total
# number of records
applicableLimits = ->
  count = indexRecordsCount()
  limits = (limit for limit in LIMITS when limit < count)
  limits.push(count)
  limits


createItem = (limit, label) ->
  uri = document.URL
  uri = updateQueryStringParameter(uri, 'per_page', limit)
  uri = updateQueryStringParameter(uri, 'page', 1)

  $link = $('<a class="batch_action">').text(label).attr('href', uri)
  if limit == currentPerPage()
    $link.addClass('active')
  $('<li>').append($link)

updateQueryStringParameter = (uri, key, value) ->
  re = new RegExp("([?&])#{key}=.*?(&|$)", 'i')
  separator = if uri.indexOf('?') != -1 then '&' else '?'

  if uri.match(re)
    uri.replace(re, "$1#{key}=#{value}$2")
  else
    "#{uri}#{separator}#{key}=#{value}"

# Return the current number of items shown
currentPerPage = ->
  initial = Math.min(30, indexRecordsCount())
  parseInt(query_param('per_page') || "#{initial}", 10)
