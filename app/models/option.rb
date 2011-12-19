class Option
  include Mongoid::Document

  field :factual_id
  key   :factual_id

  #Override in subclass
  class << self; attr_accessor :search_category,:search_table end

  field :name

  embedded_in :ballot
  has_many :votes

  def fraction
    (ballot.total_votes == 0) ? 0 : (votes.length / ballot.total_votes.to_f) * 100
  end

  def voters
    str = votes[0..4].map{|vote| vote.voter}.join(", ")
    count = votes.length
    if(count > 4)
      str + " and #{count - 4} more"
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
    end.merge(:color => color,:fraction => fraction, :voters => voters,:votes => votes)
  end

  def to_json
    as_document.to_hash.to_json
  end

  def self.get(factual_id)
    filter = {"factual_id" => {"$eq" => factual_id}}
    req = factual_client.table(APP_CONFIG['factual']['table']).filters(filter)
    Rails.logger.info(req.url)
    req.fetch
  end

  def self.search(term,options={ })
    filter = @search_category.nil? ? nil : {"category" => {"$bw" => @search_category}} # $bw == "begins_with"
    geo_filter = (options["latitude"] && options["longitude"]) ? {"$circle" => {"$center" => [options["latitude"].to_f, options["longitude"].to_f],"$meters" => APP_CONFIG['factual']['search_radius']}} : nil
    req = factual_client.table(@search_table).filters(filter).near(geo_filter).limit(APP_CONFIG['factual']['page_size']).offset((options["page"] || 1) * APP_CONFIG['factual']['page_size'] - APP_CONFIG['factual']['page_size']).search(term)
    resp = req.fetch
  end

  private

  def self.factual_client
    @factual_client ||= Factual::Client.new(APP_CONFIG['factual']['oauth_key'],APP_CONFIG['factual']['oauth_secret'] )
  end

end
