class Organization
  include Mongoid::Document
  include Mongoid::Slug

  field :name
  slug  :name

  has_one :location, :as => :addressable

  has_many :employees, :class_name => 'User'
  has_many :meals
end
