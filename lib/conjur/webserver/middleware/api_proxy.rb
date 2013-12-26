module Conjur
  module WebServer
    module Middleware
      require 'rack/proxy'
      
      class APIProxy < Rack::Proxy
        def initialize(app, opts)
          super opts

          @app = app
        end
        
        def call(env)
          path = env["PATH_INFO"]
          if serve?(path)
            super env
          else
            @app.call(env)
          end          
        end
        
        def serve?(path)
          path =~ /^\/api\//
        end
        
        def rewrite_env(env)
          env["HTTP_HOST"] = Conjur.configuration.service_url
          env["AUTHORIZATION"] = authorization_header
      
          env
        end
      
        def rewrite_response(args)
          env, status, headers, body = args
          
          source_request = Rack::Request.new(env)
      
          # Rewrite location
          if location = headers["Location"]
            headers["Location"] = location.gsub(Conjur.configuration.service_url, "http://#{source_request.host}:#{source_request.port}")
          end
      
          triplet
        end
        
        protected
        
        def authorization_header
          
        end
        
        def perform_request(env)
          triplet = super(env)
          [ env ] + triplet
        end
      end
    end
  end
end