module Conjur
  module WebServer
    require 'rack/proxy'
    
    class APIProxy < Rack::Proxy
      def rewrite_env(source_env)
        path = source_env["PATH_INFO"]
        
        path =~ /^\/([^\/]+)(.*)/
        app = $1
        path_remainder = $2

        service_url = case app
        when 'authn', 'authz', 'audit', 'pubkeys'
          path = path_remainder
          Conjur.configuration.send("#{app}_url")
        else
          Conjur.configuration.send("core_url")
        end
        service_url = URI.parse(service_url)
        host = service_url.hostname
        script = service_url.path
        
        env = source_env.with_indifferent_access.slice(*%w(REQUEST_METHOD QUERY_STRING REMOTE_ADDR REMOTE_HOST HTTP_CONNECTION HTTP_ACCEPT HTTP_X_REQUESTED_WITH HTTP_USER_AGENT HTTP_REFERER HTTP_ACCEPT_ENCODING HTTP_ACCEPT_LANGUAGE HTTP_VERSION))
        
        env.merge!({
          "HTTP_X_FORWARDED_SSL" => "on",
          "HTTP_X_FORWARDED_HOST" => host,
          "SCRIPT_NAME" => script,
          "PATH_INFO" => path,
          "HTTP_AUTHORIZATION" => authorization_header
        })

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