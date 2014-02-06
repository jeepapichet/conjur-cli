
module Conjur
  module WebServer
    class Login
      attr_reader :sessionid
      
      def initialize(sessionid)
        @sessionid = sessionid
      end
      
      def call(env)
        if sessionid = token_valid?(env)
          env["rack.session"][:sessionid] = sessionid
          response = Rack::Response.new(env)
          configuration = {
            account: Conjur.configuration.account,
            stack: Conjur.configuration.stack,
            appliance_url: Conjur.configuration.appliance_url
          }
          response.status = 302
          response.set_cookie('conjur_configuration', value: JSON.pretty_generate(configuration), path: '/')
          response['Location'] = "/ui"
          response.finish
        else
          [ 403, {}, ["Authorization is missing or invalid"] ]
        end
      end
      
      protected
      
      def token_valid?(env)
        token = extract_token(env)
        if token == sessionid
          sessionid
        else
          nil
        end
      end
      
      def extract_token(env)
        require 'cgi'
        require 'uri'
        query = URI.parse(env['REQUEST_URI']).query
        query && ( sessionid = CGI.parse(query)['sessionid'] ) && sessionid[0]
      end
    end
  end
end

