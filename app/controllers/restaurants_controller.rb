class RestaurantsController < ApplicationController
  def search
    @results = Restaurant.search(params["q"],params["latitude"],params["longitude"],params["page"] || 1)
    render :text => @results.to_json
  end
end
