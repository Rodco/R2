RSpine = require 'rspine'

class Order extends RSpine.Model
  @configure 'Order', 'Name', 'Price', 'Amount'

  constructor: -> 
    super


  # Model methods:
  # --------------
  # Update the amount of a given product on the
  # cart.
  updateAmount: (amount) ->
    @Amount = amount
    @save()


  # Collection methods:
  # -------------------
  # Add a product to the Cart.
  @addProduct: (Product) =>

    # Attempt to find product on the cart, if
    # the product exists, then update the `amount`
    # value.
    try
      cartProduct = @find Product.id
      cartProduct.updateAmount cartProduct.Amount + 1

    # If the product doesn't exist on the cart, then
    # add it, with a default `amount` value of 1.
    catch
      cartProduct = @create id: Product.id, Name: Product.Name, Price: Product.PrecioMinimo__c, Amount: 1
      cartProduct.save()


  # Return the total amount of the cart.
  @getPrice: =>
    total = @all().reduce ((x, y) -> x + (y.Price * y.Amount)), 0
    return total.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,')

  # Return the total of the cart items.
  @getTotalItems: =>
    @all().length


module.exports = Order