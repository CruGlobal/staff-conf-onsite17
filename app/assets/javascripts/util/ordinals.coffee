window.ordinal = (number) ->
  digit = number % 10
  teens = number % 100

  suffix = switch
    when digit == 1 && teens != 11 then 'st'
    when digit == 2 && teens != 12 then 'nd'
    when digit == 3 && teens != 13 then 'rd'
    else 'th'

  "#{number}#{suffix}"
