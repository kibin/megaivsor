##
# @module templates
define ['carousel', 'error', 'spinner'], (carousel, error, spinner) ->
  # Прокси для шаблонов, чтоб не прокидывать каждый шаблон по-отдельности.
  { carousel, error, spinner }
