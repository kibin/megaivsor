define ['backbone'], (Backbone) ->
  class Form extends Backbone.Model
    initialize: ->
      @carousel = @get 'carousel'

      @on 'change:url', @createCarousel
      @set 'url', (Backbone.history.fragment.split '/')[0], silent: yes

    createCarousel: ->
      catalog = (@get 'url').replace /\D+/g, ''

      @carousel.set { catalog }
