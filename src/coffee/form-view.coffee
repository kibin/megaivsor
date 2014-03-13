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
    invalid: 'Это не похоже на ссылку каталога мегавизора.'

    initialize: ({ @router }) ->
      @router
        .on 'route:catalog', @changeUrl, this
        .on 'route:main', @reset, this

      [@value, value] = ['', (@$el.find '.form-input').val()]
      @value = value if @validLink.test value

    onSubmit: (e) ->
      e.preventDefault()
      value = ($ e.delegateTarget).find('.form-input').val()

      return @showError @invalid, value unless @validLink.test value
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

    showError: (error, value) ->
      $win = $ window
      $input = @$ '.form-input'

      $input.blur().val error
        .addClass 'form-input_error'
        .one 'focus', ->
          ($input.removeClass 'form-input_error').val value
          $win.off 'keypress paste'

      $win.one 'keypress paste', ({ type }) ->
        value = '' if type is 'paste'
        $input.focus()

    reset: ->
      @fillInput()
      @model.set 'url', '', silent: on

    fillInput: (catalog) ->
      value = if catalog then "megavisor.com/catalog/#{catalog}" else ''
      (@$el.find '.form-input').val value
