##
# @module FormView
define ['backbone', 'jquery'], (Backbone, $) ->
  ##
  # @class
  class FormView extends Backbone.View
    el: '.form'
    events: 'submit': 'onSubmit'
    # Регулярка валидной ссылки. Вроде должно быть все просто.
    validLink: ///
      # Хотя... http/https, следом ://, все в начале строки, все необязательно.
      ^(https?:\/\/)?
      # Ок.
      megavisor.com
      # У сайта есть локализация /ru, но не обязательно.
      (\/ru)?
      # Хеш на сайте реврайтится медленно, поэтому ссылка может быть с ним.
      (\/\#\!)?
      # Ок.
      \/catalog
      # Цифры каталога.
      \/\d+
      # Возможный слеш в конце строки.
      \/?$
    ///
    invalid: 'Это не похоже на ссылку каталога мегавизора.'

    initialize: ({ @router }) ->
      @router
        .on 'route:catalog', @changeUrl, this
        .on 'route:main', @reset, this

      [@value, value] = ['', (@$el.find '.form-input').val()]
      @value = value if @validLink.test value

    ##
    # На сабмит нам нужно валидировать ссылку, проверять на повтор, ну и т.д.
    # @param {Object} e объект с инфой об ивенте.
    onSubmit: (e) ->
      e.preventDefault()
      $input = ($ e.delegateTarget).find('.form-input')
      value = $input.val()

      return ($input.val '').focus() unless value.trim()

      return @showError @invalid, value unless @validLink.test value
      value = value.replace /\D/g, ''

      return if value is @value.replace /\D/g, ''

      @router.navigate value
      @setUrl value

    ##
    # Добавляет каталог в урл, задает поле 'url' модели формы.
    # @param {String} value номер каталога.
    setUrl: (value) ->
      return (@$el.find '.form-input').focus() unless value
      @model.set 'url', value

    ##
    # Что делать при смене роута на каталожный. Попахивает.
    # @param {String} catalog номер каталога
    changeUrl: (catalog) ->
      @fillInput catalog
      @setUrl catalog

    ##
    # Показывает ошибку при невалидной ссылке.
    # @param {String} error текст ошибки.
    # @param {String} valus невалидная ссылка.
    showError: (error, value) ->
      $win = $ window
      $input = @$ '.form-input'

      $input.blur().val error
        .addClass 'form-input_error'
        .one 'focus', ->
          ($input.removeClass 'form-input_error').val value
          $win.off 'keypress paste'

      $win.one 'keypress paste', ({ type }) ->
        # Если юзер вставляет ссылку, вставлять обратно невалидную не надо.
        value = '' if type is 'paste'
        $input.focus()

    ##
    # Сбросывает все при роуте main. Ouch.
    reset: ->
      @fillInput()
      @model.set 'url', '', silent: on

    ##
    # Заполняет инпут, в основном, для удобства. Может заполнять пустотой. Хм.
    # @param {String} catalog номер каталога или его отсутсвие.
    fillInput: (catalog) ->
      value = if catalog then "megavisor.com/catalog/#{catalog}" else ''
      (@$el.find '.form-input').val value
