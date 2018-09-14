alreadyFired = false
registry = []

# NOTE: 'form' is a special action which will match against either 'create',
# 'new', or 'edit'
window.pageAction = (args...) ->
  len = args.length
  func = args[len - 1]
  classes = args[0..(len - 2)]

  if typeof(func) != 'function'
    throw new Error('last argument must be a function')

  if alreadyFired
    fire(func, classes)
  else
    registry.push(func: func, classes: classes)

fire = (func, classes) ->
  func($) if bodyMatchAll(classes)

bodyMatchAll = (classes) ->
  for cl in classes
    return false unless bodyMatch(cl)
  true

bodyMatch = (cl) ->
  if cl == 'form'
    bodyMatch('create') || bodyMatch('new') || bodyMatch('edit')
  else
    $(document.body).hasClass(cl)

$ ->
  alreadyFired = true
  fire(r.func, r.classes) for r in registry
  $('form:not(#housing_search_form, #collection_selection)').dirtyForms()
