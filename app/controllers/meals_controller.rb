class MealsController < ApplicationController

  def show
    @meal = Meal.where(:uuid => params[:id]).first
  end

  def new
    @meal = Meal.new(:organization_id => params[:organization_id])

    #Set default location for search, based on ip or organization location
    if(@meal.organization && @meal.organization.location)
      @meal.location = @meal.organization.location
    else
      response  = location_by_ip(request.remote_ip)
      location = [response["city"].capitalize,response['region'].upcase].join(",") rescue ""
      @meal.location = location
    end
  end

  def create
    @meal = Meal.new(params[:meal])

    if(@meal.save)
      redirect_to meal_path(@meal.uuid)
    else
      redirect_to new_meal_path
    end

  end

  private

  def location_by_ip(ip)
    return @parsed_response if @parsed_response
    ip = (ip.eql?("127.0.0.1")) ? "76.253.73.79" : ip #can't test locally...
    response  = Chimps::QueryRequest.new('web/an/de/geo.json', :query_params => { :ip => ip } ).get.parse! rescue { }
    @parsed_response ||= response
  end

end
