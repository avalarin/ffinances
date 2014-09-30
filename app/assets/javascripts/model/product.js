function ProductModel(data) {
  data = data || {}
  var product = this
  product.id = data.id
  product.unit = new UnitModel(data.unit)
  product.displayName = data.display_name
}