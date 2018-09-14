$ ->
  $.when($menu_loaded).then ->
    $('#child_family_id, #attendee_family_id').autocomplete {
      source: $housing_families,
      select: (event, ui) ->
        $(this).next('p').html(ui.item.label)
    }
  $.when($ministries_loaded).then ->
    $('#child_ministry_id, #attendee_ministry_id').autocomplete {
      source: $ministries,
      select: (event, ui) ->
        $(this).next('p').html(ui.item.label)
    }
