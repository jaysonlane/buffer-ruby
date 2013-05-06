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
      @cache = {}
      @klass_name = "profiles"
      super
    end

    def cache
      @cache[@klass_name.to_sym] ||= get @klass_name
    end

  end

  class Updates < Client
    def initialize(token)
      @cache = {}
      @klass_name = "updates"
      super
    end

    def cache
      @cache[@klass_name.to_sym] ||= get @klass_name
    end
  end

  # class Links < Client
  # end


  class Info < Client
    def initialize(token)
      @cache = {}
      @klass_name = "info/configuration"
      super
    end

    def cache
      @cache[@klass_name.to_sym] ||= get @klass_name
    end

  end

  # class ErrorCodes
  # end

end
