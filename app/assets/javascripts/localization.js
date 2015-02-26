numeral.language('ru')
moment.locale('ru')

if (!window.values) window.values = {}
if (!window.urls) window.urls = {}
if (!window.localization) window.localization = {}

numeral.replaceInvalidDelimiters = (function(){
  var decimalDelimiter = numeral.languageData().delimiters.decimal
  var thousandsDelimiter = numeral.languageData().delimiters.thousands
  var regexParts = []
  var delimiters = [',', '.']
  for (var i = 0; i < delimiters.length; i++) {
    var d = delimiters[i]
    if (d != decimalDelimiter && d != thousandsDelimiter) {
      regexParts.push(d)
    }
  }

  var invalidDelimitersRegexp = new RegExp('[' + regexParts.join('|') + ']')

  return function(value) {
    return value.replace(invalidDelimitersRegexp, numeral.languageData().delimiters.decimal)
  }
})()