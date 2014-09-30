class Data::UnitController < ApplicationController
  
  def index
    lang = params[:lang] || I18n.locale.to_s

    render_api_resp(:ok, data: Unit.all.map do |unit|
      name = unit.names[lang] || unit.names['en']
      {
        id: unit.id,
        full_name: name['full'],
        short_name: name['short'],
        decimals: unit.decimals
      }
    end)
  end

end