class Option
  include Mongoid::Document

  field :name
  field :uuid #This is the foreign id used to retrieve records from :get and :search
  field :color

  COLORS = ['#0af','#FF9797', '#B89AFE', '#7CEB98','#FFFF84','#BEFEEB']

  embedded_in :ballot
  has_many :votes

  before_create :set_color,:capitalize_name

  class << self; attr_accessor :search_table,:search_filters,:geo_filter end

  def fraction
    ballot_votes = ballot.total_votes
    (ballot_votes == 0) ? 0 : (votes.length / ballot_votes.to_f) * 100
  end

  def self.geo_filter_for(latitude,longitude,radius)
    {"$circle" => {"$center" => [latitude.to_f, longitude.to_f],"$meters" => radius.to_i}}
  end

  def self.get(uuid)
    filter  = {"factual_id" => {"$eq" => uuid}}
    request = factual_client.table(@search_table).filters(filter)
    resp = request.fetch["response"]["data"][0]
    resp.merge("uuid" => resp["factual_id"])
  end

  def self.search(term,geo_filter={},search_filters=[],page=1)
    filters    = (search_filters << @search_filters).flatten.sort.uniq.inject({ }){|filters,filter| filters.merge(filter) }
    page_size  = APP_CONFIG['factual']['page_size']
    offset     = page * page_size - page_size
    request  = factual_client.table(@search_table).filters(filters).near(geo_filter).limit(page_size).offset(offset).search(term)
    response = request.fetch

    #FIXME: With a geo_filter, Factual sends back a key that begins with '$', and MongoDB whines like a BITCH
    if(response["response"] && response["response"]["data"])
      response["response"]["data"] = response["response"]["data"].inject([]) do |opts,option|
        opts << option.inject({}) do |hsh,kv|
          hsh.delete("24")
          kv[0] = kv[0].eql?("factual_id") ? "uuid" : kv[0]
          hsh.merge(kv[0].gsub('$','') => kv[1])
        end
      end
    end
    response
  end

  def to_json
    as_document.to_hash.to_json
  end

  #FIXME: Overriding serialization so I can stuff in instance methods
  def as_document
    attributes.tap do |attrs|
      return attrs if frozen?
      relations.each_pair do |name, meta|
        if meta.embedded?
          relation = send(name)
          attrs[name] = relation.as_document unless relation.blank?
        end
      end
    end.merge(:fraction => fraction,:votes => votes.map{|v|v.as_document.to_hash})
  end

  private

  def set_color
    self.color = COLORS[ballot.options.count % COLORS.length]
  end

  def capitalize_name
    self.name = self.name.split(" ").map(&:capitalize).join(" ")
  end

  def self.factual_client
    @factual_client ||= Factual::Client.new(APP_CONFIG['factual']['oauth_key'],APP_CONFIG['factual']['oauth_secret'] )
  end

end
