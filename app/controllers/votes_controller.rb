class VotesController < ApplicationController

  def create
    @vote   = Vote.new(:option_id => params[:vote][:option][:id],:voter => params[:vote][:voter])
    if(@vote.save)
      @ballot = Ballot.where(:uuid => params[:vote][:ballot_id]).first
      redis_client.publish('dl.channel.votes',Yajl::Encoder.encode(@ballot))
      redirect_to ballot_path(params[:vote][:ballot_id])
    else
      redirect_to ballot_path(params[:vote][:ballot_id])
    end
  end

  private

  def redis_client
    @redis_client ||= Redis.new(:host => 'localhost',:port => 6379)
  end

end
