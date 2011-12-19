class OptionsController < ApplicationController
  def search
    option_klass = params[:option_klass].constantize
    geo_filter = params[:geo_filter].nil? ? {} : Yajl::Parser.parse(params[:geo_filter])
    search_filters = params[:search_filters].nil? ? [] : Yajl::Parser.parse(params[:search_filters])

    @results = option_klass.search(params[:q],geo_filter,search_filters,params[:page] || 1)
    render :json => Yajl::Encoder.encode(@results)
  end
end
