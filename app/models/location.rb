class Location
  include Mongoid::Document

  #This schema is largely ripped from Factual's Place schema
  #http://developer.factual.com/display/docs/Places+API+-+Global+Place+Attributes

  field :latitude #WGS84
  field :longitude #WGS84

  field :address
  field :address_extended

  field :locality #city,town or equivalent
  field :region #state, province, territory, or equivalent
  field :country #ISO 3166-1 alpha-2 country code

end
