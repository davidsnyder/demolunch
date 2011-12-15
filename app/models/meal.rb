class Meal
  include Mongoid::Document
  include Mongoid::Slug

  field :date, :type => DateTime

  field :uuid
  slug  :uuid

  has_one :location, :as => :addressable

  has_many   :orders
  belongs_to :restaurant
  belongs_to :organization #optional

  before_create :generate_uuid!

  #Set default location for search, based on ip or organization location
  def set_default_location(ip_address)
    return unless self.location.nil?
    if(self.organization && self.organization.location)
      self.location = self.organization.location
    else
      response     = location_by_ip(ip_address)
      location_hsh = { :latitude => response["latitude"].to_f,:longitude => response["longitude"].to_f,:locality => response["city"].capitalize,:region => response["region"].upcase,:country => response["two_letter_country"]}
      self.build_location(location_hsh)
    end
  end

  private

  def generate_uuid!
    self.uuid = ("%032x" % UUIDTools::UUID.timestamp_create.to_i)[0..8]
  end

  def location_by_ip(ip)
    return @response if @response
    ip = (ip.eql?("127.0.0.1")) ? "76.253.73.79" : ip #can't test locally...
    Chimps.config[:query][:key] = APP_CONFIG['infochimps']['apikey']
    @response ||= Chimps::QueryRequest.new('web/analytics/ip_mapping/digital_element/geo', :query_params => { :ip => ip } ).get.parse!.data
  end

end
