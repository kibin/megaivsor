##
# @module Carousel
define ['backbone'], (Backbone) ->
  ##
  # Модель карусели.
  # @class
  class Carousel extends Backbone.Model
    initialize: ->
      @cards = new (Backbone.Collection.extend model: Backbone.Model.extend())

      @on 'change:catalog', @load
      @set 'catalog', (Backbone.history.fragment.split '/')[0], silent: yes

    ##
    # Не очень красивый метод загрузки карточек с сервера.
    # @param {Object} model текущая модель, собственно, не нужна.
    # @param {String} catalog номер каталога, куда обращаться за данными.
    load: (model, catalog) ->
      @sync 'read', this,
        url: "/api/#{catalog}"
        success: (data) =>
          @trigger 'load', data
          @cards.set data.body.items if data.code is 200
