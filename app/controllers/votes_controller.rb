class VotesController < ApplicationController

  def create
    @ballot = Ballot.where(:uuid => params[:vote][:ballot_id]).first
    @option = @ballot.options.where(:uuid => params[:vote][:option_uuid]).first

    if(current_vote_id = session[:dl] && session[:dl][@ballot.uuid])
      @vote = Vote.find(current_vote_id)
    else
      @vote = Vote.new(:voter => params[:vote][:voter])
      @vote.ballot = @ballot
    end

    @vote.option = @option

    if(@vote.save)

      session[:dl] ||= {}
      session[:dl][@ballot.uuid] ||= {}
      session[:dl][@ballot.uuid] = @vote.id

      redis_client.publish('dl.channel.votes',Yajl::Encoder.encode(@ballot))
      redirect_to ballot_path(@ballot.uuid)
    else
      redirect_to ballot_path(@ballot.uuid)
    end
  end

  def update
    @vote = Vote.find(params[:id])

    @ballot = Ballot.where(:uuid => params[:vote][:ballot_id]).first
    @option = @ballot.options.where(:uuid => params[:vote][:option_uuid]).first

    @vote.option = @option

    if(@vote.save)

      session[:dl] ||= {}
      session[:dl][@ballot.uuid] ||= {}
      session[:dl][@ballot.uuid] = @vote.id

      redis_client.publish('dl.channel.votes',Yajl::Encoder.encode(@ballot)) #FIXME: this should push on its own channel?
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
