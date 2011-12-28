class Option
  include Mongoid::Document

  field :name
  field :uuid #This is the foreign id used to retrieve records from :get and :search

  embedded_in :ballot
  has_many :votes

  class << self; attr_accessor :search_table,:search_filters,:geo_filter end

  def vote_count
    @count ||= votes.length
  end

  def fraction
    ballot_votes = ballot.total_votes
    (ballot_votes == 0) ? 0 : (vote_count / ballot_votes.to_f) * 100
  end

  def voters
    str = votes[0..4].map{|vote| vote.voter}.join(", ")
    if(vote_count > 4)
      str += " and #{vote_count - 4} more"
    end
    str
  end

  def color
    "#0af"
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
    end.merge(:color => color,:fraction => fraction, :voters => voters,:votes => votes.map{|v|v.as_document.to_hash})
  end

  def to_json
    as_document.to_hash.to_json
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
          kv[0] = kv[0].eql?("factual_id") ? "uuid" : kv[0]
          hsh.merge(kv[0].gsub('$','') => kv[1])
        end
      end
    end
    response
  end

  private

  def self.factual_client
    @factual_client ||= Factual::Client.new(APP_CONFIG['factual']['oauth_key'],APP_CONFIG['factual']['oauth_secret'] )
  end

end
