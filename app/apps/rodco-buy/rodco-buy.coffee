RSpine = require("rspine")

# Models.
Product = require ('models/producto')


class RodcoBuy extends RSpine.Controller
  className: "app-canvas"
  
  elements:
    '.product-list': 'productList'
    '.categorias-list': 'categorisList'

  constructor: ->
    super
    @bind()
    @render()
    Product.query {}
  
  render: ->
    @html require("app/rodco-buy/layout")() 

  bind: ->
    Product.bind 'refresh update create', @renderProducts

  shutdown: ->
    Product.unbind 'refresh update create', @renderProducts
    @release()


  # Products methods.
  renderProducts: =>
    @productList.html require('app/rodco-buy/product_item_layout') Product.all()

  renderCategorias: =>
    categorias= (Product.Categoria__c for Product in Product ).unique()
    @categorisList.html require('app/rodco-buy/categoriaItem') Product.all()

module.exports = RodcoBuy