class Data::CountryController < ApplicationController
  
  def index
    render_api_resp :ok, data: Country.all
  end

  def currencies
    country = Country.find_by_code(params.require(:code))
    return render_api_resp :not_found unless country
    render_api_resp :ok, data: { country: country, currencies: country.currencies }
  end

end