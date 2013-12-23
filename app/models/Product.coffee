RSpine = require('rspine')

class producto extends RSpine.Model
  @configure "Producto__c", "Name", "InventarioActual__c", "PrecioMinimo__c", "DescuentoMaximo__c", "Impuesto__c", "Categoria__c", "Grupo__c"
  
  @extend RSpine.Model.SalesforceAjax
  @extend RSpine.Model.SalesforceAjax.Auto
  @extend RSpine.Model.SalesforceModel

  constructor: -> 
    super 


  # Model methods:
  # --------------
  # Format price.
  formattedPrice: -> @PrecioMinimo__c.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,')
  className: -> if @InventarioActual__c > 0 then 'primary' else 'danger'


  # Collection methods:
  # -------------------
  # Filters.
  @filters:
    '' : 'Activo__c = true'


  # Filter products by category and/or search name.
  @filter = (query) ->

    # If there is no query specified, then return
    # product list.
    return @all() if Object.keys(query).length is 0

    # Filter product by category.
    @select (item) ->
      result = true

      for key, val of query
        if key is 'name'
          re = new RegExp val, 'i'
          result = result && re.test item.Name
        else
          result = result and item[key] is val 
          
      return result


  # Build category tree.
  @buildCategoryTree = ->

    categories = Object.create null

    for p in @all()

      # Add category key to categories if the key
      # doesn't exist.
      categories[p['Categoria__c']] = [] if not categories[p['Categoria__c']]

      # Add subcategory to category if the subcategory
      # doesn't exist on the category.
      categories[p['Categoria__c']].push p['Grupo__c'] if categories[p['Categoria__c']].indexOf(p['Grupo__c']) is -1

    return categories


  # Get all categories.
  @getCategories = ->

    # Add a "TODOS" item for reseting the filter.
    categories = [ name: 'TODOS', value: '', divider: true ]

    for c in Object.keys @buildCategoryTree()
      categories.push { name: c, value: c } if typeof c is 'string'

    categories


  # Get subcategories (group) within a given category.
  @getSubCategories = (category) ->

    subcategories = [ name: 'CATEGORIAS', value: '', back: true, divider: true ]

    for sc in @buildCategoryTree()[category]
      subcategories.push { name: sc, value: sc }

    return subcategories

module.exports = producto