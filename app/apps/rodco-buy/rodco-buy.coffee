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
    '.cart-total-container': 'cartTotalContainer'
    '.cart-count': 'shoppingCartCount'
    '.order-list': 'orderList'

  events:
    'click .categorias-list .category-item': 'changeCategory'
    'click .subcategories-list .category-item': 'changeSubCategory'
    'click .product-item': 'addProduct'
    'click .remove-cart-item': 'removeProduct'
    'click .confirm-cart': 'renderOrder'
    'click .back-to-cart': 'backToCart'
    'click .confirm-buy': 'confirmCart'
    'change .product-count': 'increaseProductCount'
    'keyup .product-search': 'searchProduct'

  constructor: ->
    super
    @bind()
    @render()
    Product.query {}
  
  render: ->
    @html require('app/rodco-buy/layouts/product-list')()
    @productsFilter = Object.create null
    @shoppingCart = []

  renderOrder: ->
    @html require('app/rodco-buy/layouts/order-page')()
    @orderList.html require('app/rodco-buy/product-list/order-item') @shoppingCart
    @calculateTotal()

  confirmCart: (e) ->
    e.preventDefault()
    console.log 'I sould confirm the cart.'

  backToCart: ->
    @html require('app/rodco-buy/layouts/product-list')()
    @productsFilter = Object.create null
    @renderProducts()
    @renderCategories()
    @renderShoppingCart()


  bind: ->
    Product.bind 'refresh update create', @renderProducts

  shutdown: ->
    Product.unbind 'refresh update create', @renderProducts
    @release()


  # Products methods.
  # -----------------

  # Render products list.
  renderProducts: =>
    @productList.html require('app/rodco-buy/product-list/product-item') Product.filter(@productsFilter)
    @renderCategories() if not @subCategory


  # Search a product.
  searchProduct: (e) =>
    e.preventDefault()
    search = $(e.target).val()

    if search.length % 3 is 0
      @productsFilter.name = search
      @renderProducts()


  # Render shopping cart.
  renderShoppingCart: ->
    @shoppingCartContainer.html require('app/rodco-buy/product-list/cart-item') @shoppingCart
    @shoppingCartCount.html @shoppingCart.length


  # Cart methods.
  # -------------

  # Add a product to cart.
  addProduct: (e) =>
    e.preventDefault()
    name = $(e.currentTarget).data 'product'
    price = $(e.currentTarget).data 'price'
    exists = false

    for p in @shoppingCart
      if p.Name is name
        p.count = p.count + 1
        exists = true
        break

    @shoppingCart.push Name: name, price: price, count: 1 if not exists
    @calculateTotal()
    @renderShoppingCart()


  # Remove a product from cart.
  removeProduct: (e) =>
    e.preventDefault()
    name = $(e.currentTarget).parent().parent().data 'product'

    for i,p of @shoppingCart
      @shoppingCart.splice(i, 1) if p.Name is name

    @calculateTotal()
    @renderShoppingCart()


  # Increase the ammount of a product.
  increaseProductCount: (e) ->
    count = parseInt $(e.currentTarget).val()
    count = if count >= 0 then count else 0

    $(e.currentTarget).val count
    name = $(e.currentTarget).parent().parent().data 'product'

    for p in @shoppingCart
      p.count = count if p.Name is name

    @calculateTotal()


  # Calculate total.
  calculateTotal: ->
    total = 0

    for p in @shoppingCart
      total = total + (p.price * p.count)

    @cartTotal = total.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,')
    @cartTotalContainer.html @cartTotal


  # Category methods.
  # -----------------

  # Render categories list.
  renderCategories: =>
    @subCategoriesContainer.css display: 'none'
    @categoriesContainer.css display: 'block'
    @categoriesList.html require('app/rodco-buy/product-list/category-item') Product.getCategories()
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
    @subCategoriesList.html require('app/rodco-buy/product-list/category-item') Product.getSubCategories category
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