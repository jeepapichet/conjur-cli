module Conjur
  module WebServer
    # Verifies that the request contains the authorization token, and then strips it.
    class Authorize
      attr_reader :app, :sessionid
      
      def initialize(app, sessionid)
        @app = app
        @sessionid = sessionid
      end
      
      def call(env)
        if token_valid?(env)
          @app.call env
        else
          [403, {}, ["Authorization is missing or invalid"]]
        end
      end
      
      protected
      
      def token_valid?(env)
        request = Rack::Request.new(env)
        request.session[:sessionid] == sessionid
      end
    end
  end
end