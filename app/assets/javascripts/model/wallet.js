function Wallet(data) {
  this.key = data.key
  this.displayName = data.display_name
  this.balance = data.balance || 0
  this.imageUrl = data.image_url
  this.currency = new Currency(data.currency)
}