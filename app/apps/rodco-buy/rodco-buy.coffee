RSpine = require 'rspine'

# TODO:
# Create a Base controller (this file).
# Create a Product List controller.
# Create a Cart controller.
# Create a Category controller.
# Create a Order Page controller.

# Models.
Product = require 'app/rodco-buy/models/Product'
Cart    = require 'app/rodco-buy/models/Order'


class RodcoBuy extends RSpine.Controller
  className: "app-canvas"
  
  elements:
    '.product-list'            : 'productList'
    '.order-list'              : 'orderList'

    '.category-dropdown-label'    : 'categoryDropdown'
    '.categories-ddwn'            : 'categoriesContainer'
    '.categorias-list'            : 'categoriesList'
    '.subcategory-dropdown-label' : 'subCategoryDropdown'
    '.subcategories-list'         : 'subCategoriesList'
    '.subcategories-ddwn'         : 'subCategoriesContainer'

 
    '.shopping-cart'           : 'shoppingCart'
    '.shopping-cart-meta'      : 'shoppingCartMeta'
    '.cart-count'              : 'shoppingCartCount'
    '.cart-total-container'    : 'shoppingCartTotal'

  events:
    'click .product-item'     : 'addProduct'
    'click .remove-cart-item' : 'removeProduct'
    'keyup .product-search'   : 'searchProduct'
    'click .confirm-cart'     : 'renderOrder'
    'click .back-to-cart'     : 'render'

    'click .categorias-list .category-item'    : 'changeCategory'
    'click .subcategories-list .category-item' : 'changeSubCategory'

  constructor: ->
    super
    @bind()
    @render()
    Product.query {}
  
  render: ->
    @html require('app/rodco-buy/templates/containers/product-list')()
    @productsFilter = Object.create null
    @renderProducts()
    @renderCart()
    @renderCategories()

  renderOrder: ->
    @html require('app/rodco-buy/templates/containers/order-page')()
    @orderList.html require('app/rodco-buy/templates/items/order-item') Cart.all()
    @shoppingCartTotal.html @calculateCartTotal


  bind: ->
    Product.bind 'refresh update create', @renderProducts
    Cart.bind 'refresh update create destroy', @renderCart

  shutdown: ->
    Product.unbind 'refresh update create', @renderProducts
    Cart.unbind 'refresh update create destroy', @renderCart

    @release()


  # Product methods.
  # ----------------
  # Render product list.
  renderProducts: =>
    @productList.html require('app/rodco-buy/templates/items/product-item') Product.filter @productsFilter
    @renderCategories() if not @subCategory

  # Search a product by the input.
  searchProduct: (e) =>
    e.preventDefault()
    search = $(e.target).val()

    if search.length % 3 is 0
      @productsFilter.name = search.trim()
      @renderProducts()

  # Update product list, decreasing the amount of
  # available items.
  decreaseProductInventory: (productId, amount) ->
    product = Product.find productId
    product.InventarioActual__c = product.InventarioActual__c - amount
    product.save()


  # Category methods.
  # -----------------
  # Render categories list.
  renderCategories: =>
    @subCategoriesContainer.css display: 'none'
    @categoriesContainer.css display: 'block'
    @categoriesList.html require('app/rodco-buy/templates/items/category-item') Product.getCategories()
    @categoryDropdown.html 'TODOS'
    @subCategory = false
    
  # Change the active category for filtering purposes.
  changeCategory: (e) =>
    category = $(e.target).parent().data 'category'

    @categoryDropdown.html $(e.target).html()
    @productsFilter = if category then 'Categoria__c': category else {}
    @renderSubCategory category if category
    @renderProducts()

  # Render subcategory list when clicking a category.
  renderSubCategory: (category) ->
    @subCategoriesContainer.css display: 'block'
    @categoriesContainer.css display: 'none'
    @subCategoriesList.html require('app/rodco-buy/templates/items/category-item') Product.getSubCategories category
    @subCategoryDropdown.html category
    @subCategory = true

    setTimeout (->
      $(".subcategories-ddwn .dropdown-toggle").dropdown "toggle"
    ), 100

  # Change the actual subcategory.
  changeSubCategory: (e) =>
    subcategory = $(e.target).parent().data 'category'

    if not subcategory
      @productsFilter = {}
      @renderCategories()
      setTimeout (->
        $(".categories-ddwn .dropdown-toggle").dropdown "toggle"
      ), 100
    else
      @subCategoryDropdown.html $(e.target).html()
      @productsFilter = 'Categoria__c': @productsFilter.Categoria__c, 'Grupo__c': subcategory

    @renderProducts()

  # Cart methods.
  # -------------
  # Render shopping cart.
  renderCart: =>
    display = if Cart.all().length isnt 0 then 'block' else 'none'
    @shoppingCartMeta.css display: display

    @shoppingCart.html require('app/rodco-buy/templates/items/cart-item') Cart.all()
    @shoppingCartCount.html Cart.all().length
    @shoppingCartTotal.html @calculateCartTotal()

  # Add a product to the cart.
  addProduct: (e) =>
    e.preventDefault()
    product = Product.find $(e.currentTarget).data 'product'

    # If the current product isn't available, then exit.
    return false if product.InventarioActual__c is 0

    # Add or update the product to the cart.
    try
      cartProduct = Cart.find product.Id
      cartProduct.Amount = cartProduct.Amount + 1
    catch
      cartProduct = new Cart id: product.Id, Name: product.Name, Price: product.PrecioMinimo__c, Amount: 1

    cartProduct.save()
    @decreaseProductInventory product.Id, 1

  # Remove a product from the cart.
  removeProduct: (e) =>
    e.preventDefault()
    product = Cart.find $(e.currentTarget).parent().parent().data 'product'
    @decreaseProductInventory product.id, product.Amount * -1
    product.destroy()

  # Calculate cart total.
  calculateCartTotal: =>
    total = Cart.all().reduce ((x, y) -> x + (y.Price * y.Amount)), 0
    return total.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,')
    

module.exports = RodcoBuy