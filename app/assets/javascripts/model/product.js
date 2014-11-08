//= require model/unit

function Product(data) {
  data = data || {}
  var product = this
  product.id = data.id
  product.unit = new Unit(data.unit)
  product.displayName = data.display_name
}