class BallotsController < ApplicationController

  def show
    @ballot = Ballot.where(:uuid => params[:id]).first
    @vote   = Vote.new

    respond_to do |format|
      format.html
      format.json { render :json => @ballot.to_json }
    end
  end

  def new
    @ballot = Ballot.new(:option_klass => RestaurantOption.to_s)
    if(@ballot.option_klass.constantize < PlaceOption)
      @ballot.location = Location.new(location_for(request.remote_ip))
    end
  end

  def create
    #FAKE:
    params[:ballot][:option_klass] = RestaurantOption.to_s
    params[:ballot][:options] = RestaurantOption.search('mexican food',:latitude => 30.3,:longitude => -97.7)["response"]["data"][0..3]

    @ballot = Ballot.new(params[:ballot])
    if(@ballot.save)
      redirect_to ballot_path(@ballot.uuid)
    else
      redirect_to new_ballot_path
    end
  end

  private

  def location_for(ip_address)
    response     = location_by_ip(ip_address)
    location_hsh = { :latitude => response["latitude"].to_f,:longitude => response["longitude"].to_f,:locality => response["city"].capitalize,:region => response["region"].upcase,:country => response["two_letter_country"]}
  end

  def location_by_ip(ip)
    return @response if @response
    ip = (ip.eql?("127.0.0.1")) ? "76.253.73.79" : ip #can't test locally...
    Chimps.config[:query][:key] = APP_CONFIG['infochimps']['apikey']
    @response ||= Chimps::QueryRequest.new('web/analytics/ip_mapping/digital_element/geo', :query_params => { :ip => ip } ).get.parse!.data
  end

end
