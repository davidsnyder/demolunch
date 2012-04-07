class Option
  include Mongoid::Document

  field :name
  field :color

  COLORS = ['#0af','#FF9797', '#B89AFE', '#7CEB98','#FFFF84','#BEFEEB']

  embedded_in :ballot
  has_many :votes

  validates :name, :length => { :minimum => 1 }, :uniqueness => {:scope => :ballot,:case_sensitive => false ,:message => "must be unique"}
  before_create :set_color!,:capitalize_name!

  def fraction
    ballot_votes = ballot.total_votes
    (ballot_votes == 0) ? 0 : (votes.length / ballot_votes.to_f) * 100
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

  def set_color!
    self.color = COLORS[ballot.options.count % COLORS.length]
  end

  def capitalize_name!
    self.name = self.name.split(" ").map(&:capitalize).join(" ")
  end

end
