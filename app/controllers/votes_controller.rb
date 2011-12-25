class VotesController < ApplicationController

  def create
    @ballot = Ballot.where(:uuid => params[:vote][:ballot_id]).first
    @option = @ballot.options.where(:_id => params[:vote][:option_id]).first
    @vote   = @option.votes.new(:voter => params[:vote][:voter])

    if(@vote.save)
      redis_client.publish('dl.channel.votes',Yajl::Encoder.encode(@ballot))
      redirect_to ballot_path(@ballot.uuid)
    else
      redirect_to ballot_path(@ballot.uuid)
    end
  end

  private

  def redis_client
    @redis_client ||= Redis.new(:host => 'localhost',:port => 6379)
  end

end
