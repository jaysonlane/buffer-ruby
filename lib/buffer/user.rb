module Buffer
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
