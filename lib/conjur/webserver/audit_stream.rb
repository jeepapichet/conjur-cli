require 'eventmachine'
module Conjur
  module WebServer
    class AuditStream
      class Body
        include EM::Deferrable
        def write chunk
          @callable.call chunk
        end
        def each &block
          @callable = block
        end
      end
      
      HEADERS = {
        "Content-Type"  => "text/event-stream",
        "Connection"    => "keepalive",
        "Cache-Control" => "no-cache, no-store"
      }
      
      def call env
        body = Body.new
        stream_events(env) do |events|
          write_events body, events
        end
        [200, HEADERS, body]
      end
      
      def stream_events env, &block
        EM.defer do
          Conjur::Audit::Follower.new{ |opts| fetch_events(env, opts) }.follow &block
        end
      end
      
      # Returns [kind, id]
      def parse_path env
        %r{^/api/audit/stream/(.*?)(?:/(.*))?$} =~ env["PATH_INFO"]
        [$1, $2]
      end
      
      def fetch_events env, options
        kind, id = parse_path env
        puts "parsed #{env['PATH_INFO']} as #{kind}, #{id}"
        method, args = if kind == 'role' && id.nil?
          [:audit_current_role, [options]]
        else
          [:"audit_#{kind}", [id, options]]
        end
        api.send method, *args
      end
      
      def write_events body, events
        events.each do |e|
          body.write "id: #{e['event_id']}\n"
          body.write "data: #{JSON.generate e}\n\n"
        end
      end
      
      def api
        Conjur::API.new_from_token Conjur::Authn.authenticate
      end
    end
  end
end