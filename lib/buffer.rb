require 'buffer/version'
require 'faraday'
require 'multi_json'
require 'addressable/uri'
require 'active_support/core_ext'


module Buffer

  class InvalidToken < StandardError; end
  class InvalidResponse < StandardError; end
  class BlankResponse < StandardError; end
  class Buffer::InvalidJSON < StandardError; end

  class Client

    attr_reader :token

    # Initialize a new Buffer::Client
    #
    # Also sets up a Faraday connection object
    #
    # token - string access token for use with all API requests
    def initialize(token)
      unless token.kind_of? String
        raise Buffer::InvalidToken, "token must be a string"
      end
      @token = token

      @conn = Faraday.new :url => 'https://api.bufferapp.com/1/'
      @addr = Addressable::URI.new
    end

    # get is a shorthand method for api :get
    #
    # uri - string endpoint uri
    def get(uri)
      api :get, uri
    end

    # post is a shorthand method for api :post
    # 
    # uri - string endpoint uri
    # data - hash or array for POST body
    def post(uri, data = {})
      api :post, uri, data
    end

    # api is the root method of the Client, handling all requests.
    #
    # type - HTTP verb, :get or :post
    # url - enpoint uri, with or without .json
    # data - hash or array of data to be sent in POST body
    def api(type, uri, data = {})
      uri = append_json_to_url(uri)
      res = case type
            when :get
              get_request(uri)
            when :post
              post_request(uri, data)
            end
      # Return nil if the body is less that 2 characters long,
      # ie. '{}' is the minimum valid JSON, or if the decoder
      # raises an exception when passed mangled JSON
      begin
        # TODO: Replace nil exception handling with proper named exceptions
        load_result(res)
      rescue => e
        raise Buffer::InvalidResponse, "Response was blank\n #{e}"
      end
    end

    def post_request(uri, data)
      @conn.post do |req|
        req.url uri, :access_token => @token
        req.body = data.to_query
      end
    end

    def get_request(uri)
      @conn.get uri, :access_token => @token
    end

    def load_result(res)
      reject_invalid_response(res)
      begin
        MultiJson.load res.body
      rescue => e
        raise Buffer::InvalidJSON, "MultiJson in load_result() was unable to parse the json data"
      end
    end

    def reject_invalid_response(res)
      raise Buffer::BlankResponse unless res.body
      raise Buffer::InvalidResponse unless valid_content_length?(res)
    end

    def valid_content_length?(res)
      res.body.length >= 2
    end

    def append_json_to_url(uri)
      if uri =~ %r{\.json$}
        uri
      else
        "#{uri}.json"
      end
    end

  end

  class User < Client

    def initialize(token)
      super
      invalidate
    end

    private

      # user is a method for handling the cache of the user
      # data from the Buffer API.
      #
      # Returns a hash of user data.
      def user
        @cache[:user] ||= get 'user'
      end

    public

      # invalidate wipes the cache so that future requests
      # rebuild it from server data
      def invalidate
        @cache = {}
      end

      # method_missing steps in to enable the helper methods
      # by trying to get a particular key from self.user
      #
      # Returns the user data or the result of super
      def method_missing(method, *args, &block)
        user[method.to_s] || super
      end

      def respond_to?(name)
        user.key_exist? name
      end

  end
end
