class Ballot
  include Mongoid::Document

  field :uuid
  key   :uuid

  field :option_klass #set at ballot creation

  embeds_one :location, :as => :addressable  #optional, ballot may not be location specific

  embeds_many :options

  accepts_nested_attributes_for :options,:location

  before_create :generate_uuid!

  def total_votes
    @total_votes ||= options.inject(0){|sum,option| sum += option.votes.length}
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
    end.merge({:total_votes => total_votes})
  end

  def to_json
    hsh = as_document.to_hash
    hsh["options"] = hsh["options"].inject({ }){|opts,opt| opts.merge(opt["factual_id"] => opt)}
    hsh.to_json
  end

  private

  def generate_uuid!
    self.uuid = ("%032x" % UUIDTools::UUID.timestamp_create.to_i)[0..8]
  end

end
