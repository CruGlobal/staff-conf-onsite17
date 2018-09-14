# @return {string} The value for a given query string parameter
# @param {string} selectedParam - The name of the query parameter
window.query_param = (selectedParam) ->
  pageURL = decodeURIComponent(window.location.search.substring(1))
  params = pageURL.split('&')

  for param in params
    parameterName = param.split('=')

    if parameterName[0] == selectedParam
      return if parameterName[1] == undefined then true else parameterName[1]
