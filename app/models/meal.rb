class Meal
  include Mongoid::Document
  include Mongoid::Slug

  field :date, :type => DateTime

  field :uuid
  slug  :uuid

  has_many   :orders
  belongs_to :restaurant_option
  belongs_to :organization #optional

  before_create :generate_uuid!

  private

  def generate_uuid!
    self.uuid = ("%032x" % UUIDTools::UUID.timestamp_create.to_i)[0..8]
  end

end
