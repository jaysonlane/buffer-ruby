require 'faraday'
require 'multi_json'
require 'addressable/uri'
require 'active_support/core_ext/object/to_query'

require 'buffer/core'
require 'buffer/errors'
require 'buffer/client'
require 'buffer/user'
require 'buffer/version'

module Buffer

  class Profiles < Client
    def initialize(token)
      super
      @cache = {}
    end

    def cache
      @cache[:profiles] ||= get 'profiles'
    end

  end

  # class Updates < Client
  # end

  # class Links < Client
  # end


  # class Info < Client
  # end

  # class ErrorCodes
  # end

end
