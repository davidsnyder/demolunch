class User
  include Mongoid::Document
  include Mongoid::Slug

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  field :name
  slug  :name

  has_many :orders

  validates_presence_of :name
  validates_uniqueness_of :name, :email, :case_sensitive => false

end
