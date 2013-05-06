module Buffer
  class User < Client
    include Buffer::Core
      def initialize(token)
        super
        @cache = {}
      end

      # user is a method for handling the cache of the user
      # data from the Buffer API.
      #
      # Returns a hash of user data.
      def cache
        @cache[:user] ||= get 'user'
      end

  end
end
