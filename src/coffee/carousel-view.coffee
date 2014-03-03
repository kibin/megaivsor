define [
  'backbone', 'jquery', 'carousel', 'error', 'spinner'
], (Backbone, $, carousel, error, spinner) ->
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

    onLoad: (data) ->
      return @renderError data unless data.code is 200
      @model.cards.once 'add', @renderCarousel, this

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

    setCardInUrl: ($card) ->
      catalog = @router.currCatalog ? (Backbone.history.fragment.split '/')[0]
      route = "#{catalog}/#{($card.index ".#{@prefix}") + 1}"
      @router.navigate route, replace: on

    shiftCard: ($card, params) ->
      { id, reversed, side } = params
      index = ($card.attr 'class').match(/\d+/)?[0]
      which = if index < id then 'before' else if index > id then 'after'
      which = 'reverse' if $card.is ".#{reversed[side].clss}"

      $card.attr 'class', (@getShiftCallback which, params)

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

    showPanorama: ({ currentTarget }) =>
      $target = $ currentTarget

      @scaleCard $target
      @showVeil $target, @$el.find '.carousel-veil'

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

    showVeil: ($target, $veil) ->
      $iframe = $target.find 'iframe'
      $spinner = $target.find '.spinner'

      $veil
        .removeClass 'hidden'
        .one 'click', =>
          ($veil.add $spinner).addClass 'hidden'
          $target.removeClass "#{@prefix}_scaled"
          $iframe.attr 'src', ''

    removeCarousel: ->
      @model.set 'catalog', '', silent: on
      @model.cards.reset()
      @$el.empty()

    renderCarousel: (m, collection) ->
      @$el.html (carousel body: items: collection.toJSON())

    renderError: (data) -> @$el.html (error data)

    renderSpinner: -> @$el.html spinner()

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
