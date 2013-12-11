RSpine = require("rspine")

# Models.
Product = require ('models/producto')


class RodcoBuy extends RSpine.Controller
  className: "app-canvas"
  
  elements:
    '.category-dropdown-label': 'categoryDropdown'
    '.product-list': 'productList'
    '.categorias-list': 'categoriesList'

  events:
    'click .category-item': 'changeCategory'

  constructor: ->
    super
    @bind()
    @render()
    Product.query {}
  
  render: ->
    @html require("app/rodco-buy/layout")(@activeCategory) 

  bind: ->
    Product.bind 'refresh update create', @renderProducts

  shutdown: ->
    Product.unbind 'refresh update create', @renderProducts
    @release()


  # Products methods.
  renderProducts: =>
    @productList.html require('app/rodco-buy/product_item_layout') Product.filter(@activeCategory)
    @renderCategories()

  # Category methods.
  renderCategories: =>
    @categoriesList.html require('app/rodco-buy/categoriaItem') Product.getCategories()

  changeCategory: (e) =>
    @activeCategory = $(e.target).parent().data 'category'
    @categoryDropdown.html $(e.target).text()
    @renderProducts()

module.exports = RodcoBuy