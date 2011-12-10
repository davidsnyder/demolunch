class MealsController < ApplicationController

  def show
    @meal = Meal.where(:uuid => params[:id]).first
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
