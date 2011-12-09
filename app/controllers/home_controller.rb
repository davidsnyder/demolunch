class HomeController < ApplicationController

  def index
  end

  def socket_test
    redis_client = Redis.new(:host => 'localhost',:port => 6379)
    vote = "meal_id:#{%w(bill ted mary).sample}:#{%w(fricanos torchys subway).sample}"
    #publishes "meal_id:user_id:restaurant_id"
    redis_client.publish('dl.channel.votes',vote)
    redirect_to root_url
  end
end
