//= require model/user

function Book(data) {
  data = data || {}
  this.key = data.key
  this.displayName = data.display_name
  this.owner = new User(data.owner)
}