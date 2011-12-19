class OptionsController < ApplicationController

  def search
    @ballot = Ballot.where(:uuid => params[:ballot_id]).first
    option_klass = @ballot.option_klass.constantize
    @results = option_klass.search(params["q"],params)
    render :text => @results.to_json
  end

end
