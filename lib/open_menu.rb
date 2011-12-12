require 'httparty'

module OpenMenu
  class Client
    include HTTParty
    base_uri 'http://openmenu.com'

    attr_accessor :version

    # @apikey@ uuid key, request an account on http://openmenu.com
    # @format@ :json or :xml, defaults to :json
    # @version@ defaults to :v1
    def initialize(apikey,version=:v1,format=:json)
      raise MissingApikeyError unless apikey
      self.version = version
      self.class.default_params :key => apikey,:output => format
    end

    def menu(uuid)
      raise InvalidParametersError, "Expected String, got #{uuid.class}" unless uuid.is_a?(String)
      self.class.get("/menu/#{uuid}")
    end

    def method_missing(name,*options,&blk)
      raise InvalidParametersError, "Expected Hash of query parameters, got #{options.first.class} #{options.first}" unless options.first.is_a?(Hash)
      self.class.get("/api/#{version}/#{name}",:query => options.first)
    end

  end

  class MissingApikeyError < StandardError; end
  class InvalidParametersError < StandardError; end
end
