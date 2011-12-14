class Organization
  include Mongoid::Document
  include Mongoid::Slug

  field :name
  slug  :name

  embeds_one :location

  has_many :employees, :class_name => 'User'
  has_many :meals
end
