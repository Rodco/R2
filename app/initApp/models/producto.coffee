RSpine = require('rspine')

class producto extends RSpine.Model
  @configure "Producto__c", "Name", "InventarioActual__c", "PrecioMinimo__c", "DescuentoMaximo__c", "Impuesto__c", "Categoria__c", "Grupo__c"
  
  @extend RSpine.Model.SalesforceAjax
  @extend RSpine.Model.SalesforceAjax.Auto
  @extend RSpine.Model.SalesforceModel

  constructor: -> 
    super 


  # Filters.
  @filters:
    '' : 'Activo__c = true'


  # Filter products by category.
  @filter = (query) ->

    # If there is no query specified, then return
    # product list.
    return @all() unless query

    # Filter product by category.
    @select (item) ->
      item['Categoria__c'] is query


  # Get all categories.
  @getCategories = ->
    categories = [{
      name: 'TODOS'
      value: ''  
    }]

    for c in (p['Categoria__c'] for p in @all()).unique()
      categories.push { name: c, value: c } if typeof c is 'string'

    categories

module.exports = producto