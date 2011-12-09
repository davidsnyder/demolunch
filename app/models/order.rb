class Order
  include Mongoid::Document

  belongs_to :user
  belongs_to :meal

end
