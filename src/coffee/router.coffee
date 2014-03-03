define ['backbone'], (Backbone) ->
  class Router extends Backbone.Router
    routes:
      ':catalog/:card': 'catalog'
      ':catalog': 'catalog'
      '': 'main'

    catalog: (catalog) ->
      [@prevCatalog, @currCatalog] = [@currCatalog, catalog]
    main: ->
      [@prevCatalog, @currCatalog] = [@currCatalog, null]
