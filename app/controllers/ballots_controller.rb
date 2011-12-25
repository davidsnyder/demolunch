class BallotsController < ApplicationController

  def show
    @ballot = Ballot.where(:uuid => params[:id]).first

    @vote   = @ballot.options.first.votes.build
    @vote.option = nil #FIXME: kind of a hack

    respond_to do |format|
      format.html
      format.json { render :json => Yajl::Encoder.encode(@ballot) }
    end
  end

  def new
    @ballot = Ballot.new(:option_klass => RestaurantOption.to_s) #FIXME: Hardcoded option_klass
    if(@ballot.option_klass.constantize < PlaceOption)
#      location = location_for(request.remote_ip)
      @ballot.geo_filter = @ballot.option_klass.constantize.geo_filter_for(30.30,-97.68,APP_CONFIG['factual']['search_radius'])
    end
   end

  def create
    option_klass = params[:ballot][:option_klass]
    geo_filter   = params[:ballot][:geo_filter].nil? ? {} : Yajl::Parser.parse(params[:ballot][:geo_filter])
    search_filters = params[:ballot][:search_filters].nil? ? [] : Yajl::Parser.parse(params[:ballot][:search_filters])

    params[:ballot][:options_attributes] = (option_klass.constantize).search('mexican food',geo_filter,search_filters,params[:page]||1)["response"]["data"][0..3]

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
