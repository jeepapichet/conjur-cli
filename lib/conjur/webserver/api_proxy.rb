module Conjur
  module WebServer
    require 'rack/proxy'
    
    class APIProxy < Rack::Proxy
      def rewrite_env(env)
        # env["HTTP_HOST"] = "core-ci-conjur.herokuapp.com" # Conjur.configuration.service_url
        # env["HTTPS"] = "on"
        env["HTTP_X_FORWARDED_SSL"] = "on"
        env["HTTP_X_FORWARDED_HOST"] = "core-ci-conjur.herokuapp.com"
        env["HTTP_AUTHORIZATION"] = authorization_header
        env["PATH_INFO"] = env["PATH_INFO"].gsub(/^\/api\//, "/")
        if query = env["QUERY_STRING"]
          env["QUERY_STRING"] = query.gsub(/\bsessionid=.*\b/, "")
        end
        env.delete "HTTP_HOST"
        
        env
      end
    
      def rewrite_response(args)
        env, status, headers, body = args
        
        source_request = Rack::Request.new(env)
    
        # Rewrite location
        if location = headers["Location"]
          headers["Location"] = location.gsub(Conjur.configuration.service_url, "http://#{source_request.host}:#{source_request.port}")
        end
        
        [ status, headers, body ]
      end
      
      protected
      
      def authorization_header
        require 'conjur/authn'
        require 'base64'
        token = Conjur::Authn.authenticate
        "Token token=\"#{Base64.strict_encode64(token.to_json)}\""
      end
      
      def perform_request(env)
        triplet = super(env)
        [ env ] + triplet
      end
    end
  end
end