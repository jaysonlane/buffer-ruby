module Buffer

  module Core
    def initialize(token)
      super
      invalidate
      cache
    end


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
      cache[method.to_s] || super
    end

    def respond_to?(name)
      cache.key_exist? name
    end

  end
end
