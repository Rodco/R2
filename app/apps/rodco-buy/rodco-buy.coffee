RSpine = require("rspine")

# Models.
Product = require ('models/producto')


class RodcoBuy extends RSpine.Controller
  className: "app-canvas"
  
  elements:
    '.category-dropdown-label': 'categoryDropdown'
    '.subcategory-dropdown-label': 'subCategoryDropdown'
    '.product-list': 'productList'
    '.categorias-list': 'categoriesList'
    '.subcategories-list': 'subCategoriesList'
    '.subcategories-ddwn': 'subCategoriesContainer'
    '.categories-ddwn': 'categoriesContainer'

  events:
    'click .categorias-list .category-item': 'changeCategory'
    'click .subcategories-list .category-item': 'changeSubCategory'
    'keyup .product-search': 'searchProduct'

  constructor: ->
    super
    @bind()
    @render()
    Product.query {}
  
  render: ->
    @html require("app/rodco-buy/layout")()
    @productsFilter = Object.create null

  bind: ->
    Product.bind 'refresh update create', @renderProducts

  shutdown: ->
    Product.unbind 'refresh update create', @renderProducts
    @release()


  # Products methods.
  # -----------------

  # Render products list.
  renderProducts: =>
    @productList.html require('app/rodco-buy/product_item_layout') Product.filter(@productsFilter)
    @renderCategories() if not @subCategory

  # Search a product.
  searchProduct: (e) =>
    @productsFilter.name = $(e.target).val()
    @renderProducts()

  # Category methods.
  # -----------------

  # Render categories list.
  renderCategories: =>
    @subCategoriesContainer.css display: 'none'
    @categoriesContainer.css display: 'block'
    @categoriesList.html require('app/rodco-buy/categoriaItem') Product.getCategories()
    @categoryDropdown.html 'TODOS'
    @subCategory = false

  # Change the active category for filtering purposes.
  changeCategory: (e) =>
    category = $(e.target).parent().data 'category'

    @activeCategory = category
    @categoryDropdown.html $(e.target).html()

    @productsFilter = if category then 'Categoria__c': category else {}

    @renderSubCategory @activeCategory if category
    @renderProducts()

  # Subcategory methods.
  # --------------------

  # Render subcategory list when clicking a category.
  renderSubCategory: (category) ->
    @subCategoriesContainer.css display: 'block'
    @categoriesContainer.css display: 'none'
    @subCategoriesList.html require('app/rodco-buy/categoriaItem') Product.getSubCategories category
    @subCategoryDropdown.html category
    @subCategory = true

  # Change the actual subcategory.
  changeSubCategory: (e) =>
    subcategory = $(e.target).parent().data 'category'

    if not subcategory
      @productsFilter = {}
      @renderCategories()
    else
      @subCategoryDropdown.html $(e.target).html()
      @productsFilter = 'Categoria__c': @activeCategory, 'Grupo__c': subcategory

    @renderProducts()

module.exports = RodcoBuy