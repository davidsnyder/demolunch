class Option
  include Mongoid::Document

  field :factual_id
  key   :factual_id

  field :name

  embedded_in :ballot
  has_many :votes

  class << self; attr_accessor :search_table,:search_filters,:geo_filter end

  def fraction
    (ballot.total_votes == 0) ? 0 : (votes.length / ballot.total_votes.to_f) * 100
  end

  def voters
    str = votes[0..4].map{|vote| vote.voter}.join(", ")
    count = votes.length
    if(count > 4)
      str += " and #{count - 4} more"
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

  def self.get(factual_id)
    filter  = {"factual_id" => {"$eq" => factual_id}}
    request = factual_client.table(@search_table).filters(filter)
    request.fetch
  end

  def self.search(term,geo_filter={},search_filters=[],page=1)
    filters    = (search_filters << @search_filters).flatten.sort.uniq.inject({ }){|filters,filter| filters.merge(filter) }
    page_size  = APP_CONFIG['factual']['page_size']
    offset     = page * page_size - page_size
    request = factual_client.table(@search_table).filters(filters).near(geo_filter).limit(page_size).offset(offset).search(term)
    response = request.fetch

    #FIXME: Factual sends back a key that begins with '$', and MongoDB whines like a BITCH
    if(response["response"] && response["response"]["data"])
      response["response"]["data"] = response["response"]["data"].inject([]) do |opts,option|
        opts << option.inject({}) do |hsh,kv|
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
