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
    @ballot = Ballot.new(:option_klass => RestaurantOption.to_s) #FIXME:Hardcoded option_klass
    klass = @ballot.option_klass.constantize

    #example use of klasses, in this case only fetching location if this type of
    #poll would benefit from it
    if(klass < PlaceOption)
      #location = location_for(request.remote_ip)
      #FIXME: hardcoded location
      @ballot.geo_filter = klass.geo_filter_for(30.30,-97.68,APP_CONFIG['factual']['search_radius'])
    end
   end

  def create
    option_klass   = params[:ballot][:option_klass]
    geo_filter     = params[:ballot][:geo_filter].nil? ? {} : Yajl::Parser.parse(params[:ballot][:geo_filter])
    search_filters = params[:ballot][:search_filters].nil? ? [] : Yajl::Parser.parse(params[:ballot][:search_filters])
    options_attributes = params[:ballot].delete(:options_attributes)
    @ballot = Ballot.new(params[:ballot])

    #TODO: defaulting to 4 static options
    #options_attributes = (option_klass.constantize).search('sandwich',geo_filter,search_filters,params[:page]||1)["response"]["data"][0..3]
    options_attributes.each do |option_attrs|
      next unless option_attrs["name"].strip.length > 0
      @option = (@ballot.option_klass.constantize).new(option_attrs)
      @option.ballot = @ballot
      @option.save
    end

    if(@ballot.save)
      redirect_to ballot_path(@ballot.uuid)
    else
      redirect_to new_ballot_path
    end
  end

  def update
    @ballot = Ballot.find(params[:id])
    @ballot.options << (@ballot.option_klass.constantize).new(params[:ballot][:options_attributes])

    if(@ballot.save)
      #FIXME: hardcoded channel
      redis_client.publish('dl.channel.votes',Yajl::Encoder.encode(@ballot))
      respond_to do |format|
        format.json { render :json => Yajl::Encoder.encode(@ballot) }
      end
    else
      flash[:error] = "Noe gikk galt!"
      respond_to do |format|
        format.json { render :json => Yajl::Encoder.encode(@ballot) }
      end
    end
  end

  private

  def redis_client
    @redis_client ||= Redis.new(:host => 'localhost',:port => 6379)
  end

  def location_for(ip_address)
    response     = location_by_ip(ip_address)
    location_hsh = {:latitude => response["latitude"].to_f,:longitude => response["longitude"].to_f,:locality => response["city"].capitalize,:region => response["region"].upcase,:country => response["two_letter_country"]}
  end

  def location_by_ip(ip)
    return @response if @response
    ip = (ip.eql?("127.0.0.1")) ? "76.253.73.79" : ip #can't test locally...
    Chimps.config[:query][:key] = APP_CONFIG['infochimps']['apikey']
    #FIXME: hardcoded query path
    @response ||= Chimps::QueryRequest.new('web/analytics/ip_mapping/digital_element/geo', :query_params => { :ip => ip } ).get.parse!.data
  end

end
