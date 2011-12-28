class OptionsController < ApplicationController
  def search
    option_klass = params[:option_klass].constantize
    geo_filter = params[:geo_filter].nil? ? {} : Yajl::Parser.parse(params[:geo_filter])
    search_filters = params[:search_filters].nil? ? [] : Yajl::Parser.parse(params[:search_filters])

    @results = option_klass.search(params[:q],geo_filter,search_filters,params[:page] || 1)
    render :json => Yajl::Encoder.encode(@results)
  end

  def show
    option_klass = params[:option_klass].constantize || Option
    @option = option_klass.get(params[:id])
    @option_template = Mustache.render(Haml::Engine.new(File.read(File.join(File.dirname(__FILE__),"../views/options/_#{option_klass.to_s.underscore}.html.haml"))).render,@option)

    respond_to do |format|
      format.html { render :layout => false}
      format.json { render :json => Yajl::Encoder.encode(@option) }
    end
  end
end
