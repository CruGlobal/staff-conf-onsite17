createPositionSelectors = ->
  page = query_param('page') || 1
  perPage = query_param('per_page') || 30
  lastIndex = indexRecordsCount()

  createSelectors(positionOptions(lastIndex))


positionOptions = (lastIndex) ->
  {value: position, name: ordinal(position)} for position in [1..lastIndex]


createSelectors = (options) ->
  $('.index_table tbody tr').each ->
    path = updatePath($(this).find('a.view_link').attr('href'))
    $positionCell = $(this).find('.col-position')

    position = parseInt($positionCell.text(), 10)
    $selector = createSingleSelector(position, options, path)

    $positionCell.empty().append($selector)


updatePath = (root_path) -> "#{root_path}/reposition"


createSingleSelector = (index, options, path) ->
  $select = $('<select>').append(createOptions(options, index))

  $select.on 'change', ->
    $.ajax(
      headers:
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      url: path
      type: 'PATCH'
      data:
        position: $select.val()
    )
      .done -> window.location.reload(true)


createOptions = (options, selected) ->
  for opt in options
    $option = $('<option>').attr('value', opt['value']).text(opt['name'])
    $option.prop('selected', selected == opt['value'])


pageAction 'childcares', 'index', createPositionSelectors
pageAction 'conferences', 'index', createPositionSelectors
pageAction 'courses', 'index', createPositionSelectors
