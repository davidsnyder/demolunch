class MealsController < ApplicationController

  def show
    @meal = Meal.where(:uuid => params[:id]).first
    @meal.set_default_location(request.remote_ip)
  end

  def new
    @meal = Meal.new(:organization_id => params[:organization_id])
    @meal.set_default_location(request.remote_ip)
  end

  def create
    #FAKE:
    params[:options] = Restaurant.search('mexican food',30.3,-97.7)["response"]["data"][0..3].map{|place|{"id" => place["uuid"],"name" => place["name"] }}

    @meal = Meal.new(params[:meal])
    if(@meal.save)
      redis_client = Redis.new(:host => 'localhost',:port => 6379) #pull this out
      option_ids  = params[:options].map{|opt|opt["id"]}
      options = params[:options].inject([]){|opts,opt| opts << opt["id"] << opt["name"] }
      redis_client.multi do #enter a transaction
        redis_client.sadd("#{@meal.uuid}:options",*option_ids)
        redis_client.hmset("options",*options)
      end

      redirect_to meal_path(@meal.uuid)
    else
      redirect_to new_meal_path
    end
  end

end
