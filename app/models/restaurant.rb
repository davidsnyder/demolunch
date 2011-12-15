class Restaurant
  include Mongoid::Document

  field :factual_id
  key   :factual_id

  field :name
  field :phone
  field :category
  field :url

  has_one :location, :as => :addressable

  has_many :meals
  has_one  :menu
  has_many :orders

  accepts_nested_attributes_for :location
  validates_uniqueness_of :factual_id, :case_sensitive => false

  def self.search(term,latitude=nil,longitude=nil,page_num=1)
    results = { "total" => 0,"results" => []}
    filters = {"category" => {"$bw" => APP_CONFIG['factual']['search_category']}} # $bw == "begins_with"
    if(latitude && longitude)
      filters = filters.merge("$loc" => {"$within" => {"$center" => [[latitude.to_f, longitude.to_f],APP_CONFIG['factual']['search_radius']]}})
    end
    # This shit takes 2 seconds....
    places_table.filter(filters).page(page_num,:size => APP_CONFIG['factual']['page_size']).search(term).each_row{ |row|
      results["results"] << Restaurant.build_from_row(row)
      results["total"]+=1
    }
    results
  end

  def menu
    return @menu if @menu
    if APP_CONFIG['openmenu']['apikey']
      crosswalk_resp = Restaurant.om_client.crosswalk(:crosswalk => self.factual_id).parsed_response #look for a cross reference on openmenu
      if(crosswalk_resp)
        menu_uuid = crosswalk_resp["response"]["result"].first[1]["openmenu_id"]
        @menu ||= Restaurant.om_client.menu(menu_uuid).parsed_response["omf"]["menus"]["menu"]
      else
        @menu ||= nil
      end
    end
  end

  private

  def self.factual_client
    @factual_client ||= Factual::Api.new(:api_key => APP_CONFIG['factual']['apikey'])
  end

  def self.om_client
    @om_client ||= OpenMenu::Client.new(APP_CONFIG['openmenu']['apikey'])
  end

  def self.places_table
    @places ||= factual_client.get_table(APP_CONFIG['factual']['places_table'])
  end

  #%w(factual_id name address address_extended po_box locality region country postcode tel fax category website email latitude longitude status)
  #["42b9fdd6-4ced-4efe-a0fd-9dbabae3e4dc", "Five Guys Burgers & Fries", "3208 Guadalupe St", "# B", nil, "Austin", "TX", "US", "78705", "(512) 452-4300", nil, "Food & Beverage > Restaurants > Fast Food", "http://www.fiveguys.com", nil, 30.299782, -97.740067, "1"]
  def self.build_from_row(factual_row)
    hsh = {
      :factual_id => factual_row.subject.first,
      :name => factual_row["name"].to_s,
      :phone => factual_row["tel"].to_s,
      :category => factual_row["category"].to_s,
      :url => factual_row["website"].to_s,
      :location => {
        :address => factual_row["address"].to_s,
        :address_extended => factual_row["address_extended"].to_s,
        :latitude => factual_row["latitude"].to_s,
        :longitude => factual_row["longitude"].to_s,
        :locality => factual_row["locality"].to_s,
        :region => factual_row["region"].to_s,
        :country => factual_row["country"].to_s
      }
    }
    Restaurant.new(hsh)
  end

end
