##
# @module CarouselView
define ['backbone', 'jquery', 'templates'], (Backbone, $, templates) ->
  ##
  # Вью карусели.
  # @class
  class CarouselView extends Backbone.View
    el: '.carousel'
    events:
      'click .carousel-card_right': 'makeActive'
      'click .carousel-card_left': 'makeActive'
      'click .carousel-card_active': 'showPanorama'

    prefix: 'carousel-card'

    initialize: ({ @router }) ->
      [@lclass, @rclass, @aclass] =
        ["#{@prefix}_left", "#{@prefix}_right", "#{@prefix}_active"]

      @model
        .on 'change:catalog', @renderSpinner, this
        .on 'load', @onLoad, this
      @router.on 'route:main', @removeCarousel, this

    ##
    # Рендерит ошибку при 403/404, на add рендерит карусель.
    # @param {Object} data коллекция моделей карточек.
    onLoad: (data) ->
      return @renderError data unless data.code is 200
      @model.cards.once 'add', @renderCarousel, this

    ##
    # Меняет классы карточкам, запускает хелперы.
    # @param {Object} eventObject — но нам нужна только нода текущей карточки.
    makeActive: ({ currentTarget }) =>
      $card = $ currentTarget
      classlist = $card.attr 'class'
      id = Number (classlist.replace /\D/g, '')
      side = (classlist.match /right|left/)?[0]
      reversed =
        left: name: 'right', clss: @rclass
        right: name: 'left', clss: @lclass

      @setCardInUrl $card

      for card in (@$el.find ".#{@lclass}, .#{@rclass}")
        @shiftCard ($ card), { id, reversed, side }

      (@$el.find ".#{@aclass}").attr 'class',
        "#{@prefix} #{reversed[side].clss} #{reversed[side].clss}_#{id}"

      $card.attr 'class', "#{@prefix} #{@aclass}"

    ##
    # Хелпер, который добавляет к урлу номер карточки.
    # @param {Object} $card нода карточки в jquery-обертке.
    setCardInUrl: ($card) ->
      catalog = @router.currCatalog ? (Backbone.history.fragment.split '/')[0]
      route = "#{catalog}/#{($card.index ".#{@prefix}") + 1}"
      @router.navigate route, replace: on

    ##
    # Меняет класс карточке в зависимости от ее положения.
    # @param {Object} $card нода карточки в jq-обертке.
    # @param {Object} params { айдишник карточки, сторона, обратная сторона }.
    shiftCard: ($card, params) ->
      { id, reversed, side } = params
      index = ($card.attr 'class').match(/\d+/)?[0]
      which = if index < id then 'before' else if index > id then 'after'
      which = 'reverse' if $card.is ".#{reversed[side].clss}"

      $card.attr 'class', (@getShiftCallback which, params)

    ##
    # Возвращает колбек, заменяющий классы в соответствие с аргументами.
    # @param {String} which где карточка по отношению к кликнутой.
    # @param {Object} params { айдишник карточки, сторона, обратная сторона }.
    # @return {Function} колбек для смены класса.
    getShiftCallback: (which, params) ->
      return $.noop unless which
      { id, reversed, side } = params

      callbacks =
        after: (i, val) ->
          val.replace /\d+/, (matched) -> Math.abs matched - (id + 1)
        before: (i, val) ->
          (val.split side).join reversed[side].name
            .replace /\d+/, (matched) -> Math.abs matched - (id - 1)
        reverse: (i, val) ->
          val.replace /\d+/, (matched) -> (Number matched) + id + 1

      callbacks[which]

    ##
    # Запускает на кликнутой карточке скейл, запускает метод «показа» «вуали».
    # @param {Object} eventObject нужна только текущая кликнутая нода.
    showPanorama: ({ currentTarget }) =>
      $target = $ currentTarget

      @scaleCard $target
      @showVeil $target, @$el.find '.carousel-veil'

    ##
    # Скейлит карту, показывает/скрывает спиннер, загружает айфрейм.
    # @param {Object} $target нода кликнутой карты, обернутая в jq.
    scaleCard: ($target) ->
      $iframe = $target.find 'iframe'
      $spinner = $target.find '.spinner'

      $target
        .addClass "#{@prefix}_scaled"
        .one (@whichTransition $target[0]), ->
          $spinner.removeClass 'hidden'
          $iframe
            .attr 'src', -> $iframe.attr 'data-src'
            .on 'load', -> $spinner.addClass 'hidden'

    ##
    # Активирует «вуаль», на клик выгружает айфрейм и скейлит обратно карточку.
    # @param {Object} $target нода кликнутой карты в jq-обертке.
    # @param {Object} $veil нода кликнутой «вуали» в jq-обертке.
    showVeil: ($target, $veil) ->
      $iframe = $target.find 'iframe'
      $spinner = $target.find '.spinner'

      $veil
        .removeClass 'hidden'
        .one 'click', =>
          ($veil.add $spinner).addClass 'hidden'
          $target.removeClass "#{@prefix}_scaled"
          $iframe.attr 'src', ''

    ##
    # Удаляет карусель. Обнуляет каталог, коллекцию карточек, вью карусели.
    removeCarousel: ->
      @model.set 'catalog', '', silent: on
      @model.cards.reset()
      @$el.empty()

    ##
    # Рендерит коллекцию карточек.
    # @param {Object} m модель, здесь не нужна.
    # @param {Object} collection коллекция карточек.
    renderCarousel: (m, collection) ->
      @$el.html (templates.carousel body: items: collection.toJSON())

    ##
    # Рендерит ошибку.
    # @param {Object} data json с инфой для ошибки.
    renderError: (data) -> @$el.html (templates.error data)

    ##
    # Рендерит спиннер.
    renderSpinner: -> @$el.html templates.spinner()

    ##
    # Возвращает правильное название для transitionEnd. Из modernizr'а.
    # @param {Object} target нода для проверки.
    # @return {String} название ивента.
    whichTransition: (target) ->
      transitionend = 'transitionend'

      events =
        transition: 'transitionend'
        OTransition: 'oTransitionEnd'
        MozTransition: 'transitionend'
        WebkitTransition: 'webkitTransitionEnd'
        MsTransition: 'msTransitionEnd'

      for transition, event of events when target.style[transition]?
        transitionend = event
        break

      transitionend
