function Currency(data) {
  data = data || {}
  this.id = data.id
  this.code = data.code
  this.symbol = data.symbol
  this.name = data.name
  this.globalName = data.global_name
}