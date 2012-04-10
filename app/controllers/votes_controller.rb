class VotesController < ApplicationController

  def create
    @ballot = Ballot.where(:uuid => params[:vote][:ballot_id]).first
    @option = @ballot.options.find(params[:vote][:option_id])

    if(cookies.signed[@ballot.uuid])
      @vote = Vote.find(cookies.signed[@ballot.uuid])
    else
      @vote = Vote.new(:voter => params[:vote][:voter])
      @vote.ballot = @ballot
    end

    @vote.option = @option

    if(@vote.save)

      cookies.signed[@ballot.uuid] = { :value => @vote.id, :expires => 24.hours.from_now }

      REDIS.publish('dl.channel.votes',Yajl::Encoder.encode(@ballot))
      redirect_to ballot_path(@ballot.uuid)
    else
      redirect_to ballot_path(@ballot.uuid)
    end
  end

  def update
    @vote = Vote.find(params[:id])

    @ballot = Ballot.where(:uuid => params[:vote][:ballot_id]).first
    @option = @ballot.options.find(params[:vote][:option_id])

    @vote.option = @option

    if(@vote.save)
      cookies.signed[@ballot.uuid] = { :value => @vote.id, :expires => 24.hours.from_now }
      REDIS.publish('dl.channel.votes',Yajl::Encoder.encode(@ballot)) #FIXME: this should push on its own channel?
      redirect_to ballot_path(@ballot.uuid)
    else
      redirect_to ballot_path(@ballot.uuid)
    end
  end

end
