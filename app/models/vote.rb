class Vote
  include Mongoid::Document
  include Mongoid::Timestamps

  #belongs_to :voter, :class_name => "User"
  field :voter #FIXME: Just storing string name until we start handling real users
  belongs_to :option

end
