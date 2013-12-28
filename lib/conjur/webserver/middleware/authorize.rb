module Conjur
  module WebServer
    module Middleware
      # Verifies that the request contains the authorization token, and then strips it.
      class Authorize
        attr_reader :app, :sessionid
        
        def initialize(app, sessionid)
          @app = app
          @sessionid = sessionid
        end
        
        def call(env)
          if token_valid?(env)
            env.delete 'Authorization'
            @app.call env
          else
            [403, {}, ["Authorization is missing or invalid"]]
          end
        end
        
        protected
        
        def token_valid?(env)
          token = extract_token(env)
          if token
            token == sessionid
          else
            false
          end
        end
        
        def extract_token(env)
          if authorization = env['Authorization']
            match = /^Token token="(.*)"/.match(authorization)
            match && match[1]
          else
            require 'cgi'
            require 'uri'
            query = URI.parse(env['REQUEST_URI']).query
            query && ( sessionid = CGI.parse(query)['sessionid'] ) && sessionid[0]
          end
        end
      end
    end
  end
end