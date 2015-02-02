//= require model/currency

function Wallet(data) {
  this.key = data.key
  this.displayName = data.display_name
  this.balance = data.balance || 0
  this.balanceText = numeral(this.balance).format('0,0.00')
  this.imageUrl = data.image_url
  this.currency = new Currency(data.currency)
}