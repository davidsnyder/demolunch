class Restaurant
  include Mongoid::Document

  field :name
  field :phone
  field :address
  field :url

  has_many :meals
  has_one  :menu
  has_many :orders

end
