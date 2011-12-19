class Vote
  include Mongoid::Document
  include Mongoid::Timestamps

  #  belongs_to :voter, :class_name => "User"
  field :voter
  belongs_to :option

  validates_presence_of :voter

end
