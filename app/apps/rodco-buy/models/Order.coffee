RSpine = require 'rspine'

class Order extends RSpine.Model
  @configure 'Order', 'Name', 'Price', 'Amount'

  constructor: -> 
    super 


module.exports = Order