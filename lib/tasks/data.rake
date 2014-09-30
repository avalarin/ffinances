namespace :data do
  
  task units: :environment do
    Unit.delete_all
    Unit.create [
      { names: { ru: { full: 'Штуки', short: 'шт' }, en: { full: 'Pieces', short: 'pcs' } }, decimals: 0 },
      { names: { ru: { full: 'Литры', short: 'л' }, en: { full: 'Litre', short: 'l' } }, decimals: 2 },
      { names: { ru: { full: 'Килограммы', short: 'кг' }, en: { full: 'Кilogram', short: 'kg' } }, decimals: 2 },
    ]
  end

end