define ['backbone', 'jquery'], (Backbone, $) ->
  class FormView extends Backbone.View
    el: '.form'
    events: 'submit': 'onSubmit'
    validLink: ///
      ^(https?:\/\/)?
      megavisor.com
      (\/ru)?
      (\/\#\!)?
      \/catalog
      \/\d+
      \/?$
    ///
    invalid: 'Это не похоже на ссылку мегавизора.'

    initialize: ({ @router }) ->
      @router
        .on 'route:catalog', @changeUrl, this
        .on 'route:main', @reset, this

      @value = (@$el.find '.form-input').val()

    onSubmit: (e) ->
      e.preventDefault()
      value = ($ e.delegateTarget).find('.form-input').val()

      return @showError @invalid unless @validLink.test value
      value = value.replace /\D/g, ''

      return if value is @value.replace /\D/g, ''

      @router.navigate value
      @setUrl value

    setUrl: (value) ->
      return (@$el.find '.form-input').focus() unless value
      @model.set 'url', value

    changeUrl: (catalog) ->
      @fillInput catalog
      @setUrl catalog

    showError: (error) ->
      $win = $ window
      $input = @$ '.form-input'

      $input.blur().val error
        .addClass 'form-input_error'
        .one 'focus', ->
          $input.removeClass('form-input_error').val ''
          $win.off 'keydown'

      $win.one 'keydown', -> $input.focus()

    reset: ->
      @fillInput()
      @model.set 'url', '', silent: on

    fillInput: (catalog) ->
      value = if catalog then "megavisor.com/catalog/#{catalog}" else ''
      (@$el.find '.form-input').val value
