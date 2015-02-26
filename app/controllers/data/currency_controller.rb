class Data::CurrencyController < ApplicationController

  def index
    data = { all: Currency.all.order(:name) }
    if current_book
      data[:top] = current_book.top_currencies
    end
    render_api_resp :ok, data: data
  end

  def rate
    @base_code = params.require(:base)
    @target_code = params.require(:target)

    return render_api_resp :bad_request, message: "Parameter 'base' required." unless @base_code
    return render_api_resp :bad_request, message: "Parameter 'target' required." unless @target_code

    @base = Currency.find_by_code(@base_code)
    @target = Currency.find_by_code(@target_code)

    return render_api_resp :bad_request, message: "Currency #{@base_code} not found." unless @base
    return render_api_resp :bad_request, message: "Currency #{@target_code} not found." unless @target

    @rate = CurrencyRate.get(@base, @target)
    unless @rate && @rate.date.to_date == DateTime.now.to_date
      @rate = @rate || CurrencyRate.new(base: @base, target: @target)
      @rate.date = DateTime.now
      resp_obj = Net::HTTP.get_response('rate-exchange.appspot.com',"/currency?from=#{@base_code}&to=#{@target_code}")
      resp = JSON.parse(resp_obj.body)
      @rate.value = resp['rate']
      @rate.save!
    end
    render_api_resp :ok, data: {
      base: @base.code,
      target: @target.code,
      date: @rate.date,
      value: @rate.value
    }
  end

end