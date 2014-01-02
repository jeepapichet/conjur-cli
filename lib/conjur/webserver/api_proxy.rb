module Conjur
  module WebServer
    require 'rack/proxy'
    
    class APIProxy < Rack::Proxy
      def rewrite_env(env)
        env["HTTP_X_FORWARDED_SSL"] = "on"
        path = env["PATH_INFO"]
        if path =~ /^\/api\/([^\/]+)\//
          app = $1
          env["HTTP_X_FORWARDED_HOST"] = "#{app}-ci-conjur.herokuapp.com"
        else
          env["HTTP_X_FORWARDED_HOST"] = "core-ci-conjur.herokuapp.com"
        end
        env["HTTP_AUTHORIZATION"] = authorization_header
        env["PATH_INFO"] = path.gsub(/^\/api\//, "/")
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