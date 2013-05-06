module Buffer
  class User < Client
    include Buffer::Core

      # user is a method for handling the cache of the user
      # data from the Buffer API.
      #
      # Returns a hash of user data.
      def cache_result
        @cache[:user] ||= get 'user'
      end

  end
end
