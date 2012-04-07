class Ballot
  include Mongoid::Document

  field :uuid
  field :expire,:type => Date
  key   :uuid

  field :option_klass #set at ballot creation, used to tune search results
  field :search_filters,:type => Array,:default => []
  field :geo_filter,:type => Hash,:default => {}

  embeds_many :options
  has_many :votes

  accepts_nested_attributes_for :options

  before_create :generate_uuid!

  def option_klass_template
    self.option_klass.to_s.underscore
  end

  def total_votes
    votes.count
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
    end.merge({:total_votes => votes.count})
  end

  def to_json
    hsh = as_document.to_hash
    hsh["options"] = hsh["options"].inject({ }){|opts,opt| opts.merge(opt["uuid"] => opt)}
    hsh.to_json
  end

  private

  def generate_uuid!
    self.uuid = ("%032x" % UUIDTools::UUID.timestamp_create.to_i)[0..8]
  end

end
