class HomeController < ApplicationController

  def index
  end

  def socket_test
    redis_client = Redis.new(:host => 'localhost',:port => 6379)

    #REMOVE: test data to populate chart

    restaurants = %w(Fricanos Torchys Subway)
    restaurant_ids = %w(fricanos-id torchys-id subway-id)
    rests = Hash[restaurants.zip(restaurant_ids)]

    names = %w(Bill Ted Mary Bob)
    usernames = %w(@bill @ted @mary @bob)
    users = Hash[names.zip(usernames)]

    name = users.keys.sample
    restaurant = rests.keys.sample

    #END REMOVE

    vote_hsh = {
      "session_id" => params[:meal][:id],
      "vote" => {
        "user" => {
          "id" => users[name],"name" => name
        },
        "option" => {
          "id" => rests[restaurant],"name" => restaurant
        }
      }
    }

    Rails.logger.info(vote_hsh.to_json)
    redis_client.publish('dl.channel.votes',vote_hsh.to_json)
    redirect_to meal_path(params[:meal][:id])
  end
end
