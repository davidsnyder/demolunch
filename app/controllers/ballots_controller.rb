class BallotsController < ApplicationController

  def show
    @ballot = Ballot.where(:uuid => params[:id]).first

    current_vote_id = session[:dl] && session[:dl][@ballot.uuid]
    @vote = current_vote_id && Vote.find(current_vote_id) || Vote.new

    respond_to do |format|
      format.html
      format.json { render :json => Yajl::Encoder.encode(@ballot) }
    end
  end

  def new
    @ballot = Ballot.new
   end

  def create
    options_attrs = params[:ballot].delete(:options_attributes)
    @ballot = Ballot.new(params[:ballot])
    options_attrs.each do |option_attrs|
      next if option_attrs["name"].strip.length == 0 #FIXME: reject_if proc not
      #working right in Ballot
      Option.new(option_attrs.merge({:ballot => @ballot })).save
    end

    if(@ballot.save)
      redirect_to ballot_path(@ballot.uuid)
    else
      @ballot.errors.full_messages.each do |msg|
        flash[:error] = msg
      end
      redirect_to new_ballot_path
    end
  end

  def update
  end

end
