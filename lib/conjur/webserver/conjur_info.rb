module Conjur
  module WebServer
    # Middleware that adds some conjur info to the rack environment
    class ConjurInfo
      def initialize app
        @app = app
      end
      
      def call env
        update_env env
        @app.call env
      end
      
      def update_env env
        PROPERTIES.each{|name| env["conjur.#{name}"] = send(name)}
      end
      
      PROPERTIES = %w(roleid account stack)
      
      def roleid
        "#{account}:user:#{Conjur::Authn.get_credentials[0]}"
      end
      
      def account
        Conjur.account
      end
      
      def stack
        Conjur.stack
      end
    end
  end
end