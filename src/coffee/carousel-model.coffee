define ['backbone'], (Backbone) ->
  class Carousel extends Backbone.Model
    initialize: ->
      @cards = new (Backbone.Collection.extend model: Backbone.Model.extend())

      @on 'change:catalog', @load
      @set 'catalog', (Backbone.history.fragment.split '/')[0], silent: yes

    load: (model, catalog) ->
      @sync 'read', this,
        url: "/api/#{catalog}"
        success: (data) =>
          @trigger 'load', data
          @cards.set data.body.items if data.code is 200
