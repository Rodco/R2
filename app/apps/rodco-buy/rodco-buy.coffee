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
    '.shopping-cart': 'shoppingCartContainer'

  events:
    'click .categorias-list .category-item': 'changeCategory'
    'click .subcategories-list .category-item': 'changeSubCategory'
    'click .product-item': 'addProduct'
    'keyup .product-count': 'increaseProductCount'
    'keyup .product-search': 'searchProduct'

  constructor: ->
    super
    @bind()
    @render()
    Product.query {}
  
  render: ->
    @html require("app/rodco-buy/layout")()
    @productsFilter = Object.create null
    @shoppingCart = []

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

  # Add a product to cart.
  addProduct: (e) =>
    e.preventDefault()
    name = $(e.currentTarget).data 'product'
    exists = false

    for p in @shoppingCart
      if p.Name is name
        p.count = p.count + 1
        exists = true
        break

    @shoppingCart.push Name: name, count: 1 if not exists
    @renderShoppingCart()

  # Render shopping cart.
  renderShoppingCart: ->
    @shoppingCartContainer.html require('app/rodco-buy/cart-item') @shoppingCart

  # Increase the ammount of a product.
  increaseProductCount: (e) ->
    count = $(e.currentTarget).val()
    name = $(e.currentTarget).parent().parent().data 'product'

    for p in @shoppingCart
      p.count = parseInt(count) if p.Name is name

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