function Unit(data) {
  data = data || {}
  var unit = this
  unit.id = data.id
  unit.shortName = data.short_name
  unit.fullName = data.full_name
  unit.decimals = data.decimals
}