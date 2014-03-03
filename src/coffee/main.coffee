require.config
  paths:
    jquery: 'vendor/jquery/dist/jquery'
    underscore: 'vendor/underscore/underscore'
    backbone: 'vendor/backbone/backbone'
    runtime: 'vendor/jade/runtime'
    carousel: '../views/carousel'
    error: '../views/error'
    spinner: '../views/spinner'

require [
  'router', 'carousel-model', 'carousel-view', 'form-model', 'form-view'
], (Router, Carousel, CarouselView, Form, FormView) ->
  router = new Router
  Backbone.history.start pushState: on, silent: on

  carousel = new Carousel
  form = new Form { carousel }
  carouselView = new CarouselView { model: carousel, router }
  new FormView { model: form, router }
