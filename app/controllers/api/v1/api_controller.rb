module Api
  module V1
    # :nodoc:
    class ApiController < ActionController::API
      include Error::Handler
      def validate_auth_token!
        return if request.headers['HTTP_KEO_AUTH_TOKEN'] == ENV['KEO_AUTH_TOKEN']
        render status: 401,
               json: { meta: { message: { text: 'Invalid auth token.' } } }
      end
    end
  end
end
