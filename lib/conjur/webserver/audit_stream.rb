require 'eventmachine'
require 'conjur/audit/humanizer'

module Conjur
  module WebServer
    class AuditStream
      include Conjur::Audit::Humanizer
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
        # This could be a lot more "EventMachineish" by using for example
        # EM::HttpRequest, but putting it in the thread pool should be
        # good enough for our purposes.
        EM.defer do
          follower = Conjur::Audit::Follower.new{|opts| fetch_events(env, opts)}
          follower.filter{|e| self_event?(env, e)} unless show_self_events?(env)
          follower.follow &block
        end
      end
      
      # Returns true if this looks like a permission check performed by the
      # audit service
      def self_event? env, e
        e['action'] == 'check' && e['asset'] == 'resource' && e['conjur_role'] == e['role'] && e['role'] == env['conjur.roleid']
      end
      
      def show_self_events? env
        !!Rack::Request.new(env).params['self']
      end
      
      # Returns [kind, id]
      def parse_path env
        path = env["SCRIPT_NAME"] + env["PATH_INFO"]
        %r{^/api/audit/stream/(.*?)(?:/(.*))?$} =~ path
        [$1, $2]
      end

      def fetch_events env, options
        kind, id = parse_path env
        args = if kind == 'role' && id.nil?
          [:audit_current_role, options] 
        else
          [:"audit_#{kind}", id, options]
        end
        api.send(*args).each{|e| humanize(e)}
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
