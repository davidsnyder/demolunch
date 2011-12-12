class MealsController < ApplicationController

  def show
    @meal = Meal.where(:uuid => params[:id]).first

    if ENV['OPEN_MENU_APIKEY']
      @om_client = OpenMenu::Client.new(ENV['OPEN_MENU_APIKEY'])
      @menu = @om_client.menu("3b164192-15bb-11e0-b40e-0018512e6b26").parsed_response["omf"]["menus"]["menu"]
    end
  end

  def new
    @meal = Meal.new(:organization_id => params[:organization_id])
  end

  def create
    @meal = Meal.new(params[:meal])

    if(@meal.save)
      redirect_to meal_path(@meal.uuid)
    else
      redirect_to new_meal_path
    end

  end

end
