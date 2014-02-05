#
# Copyright (C) 2013 Conjur Inc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module Conjur
  module WebServer
    # Launch a web server which serves local files and proxies to the remote Conjur API.
    class Server
      def start(root)
        require 'rack'
        require 'conjur/webserver/login'
        require 'conjur/webserver/authorize'
        require 'conjur/webserver/api_proxy'
        require 'conjur/webserver/home'
        require 'conjur/webserver/audit_stream'
        
        sessionid = self.sessionid
        cookie_options = {
          secret: SecureRandom.hex(32),
          expire_after: 24*60*60
        }
        app = Rack::Builder.app do
          map "/login" do
            use Rack::Session::Cookie, cookie_options
            run Conjur::WebServer::Login.new sessionid
          end
          map "/api/audit/stream" do
            use Rack::Session::Cookie, cookie_options
            use Conjur::WebServer::Authorize, sessionid
            run Conjur::WebServer::AuditStream.new
          end
          map "/api" do
            use Rack::Session::Cookie, cookie_options
            use Conjur::WebServer::Authorize, sessionid
            run Conjur::WebServer::APIProxy.new
          end
          %w(js css fonts images).each do |path|
            map "/#{path}" do
              run Rack::File.new(File.join(root, path))
            end
          end
          map "/ui" do
            run Conjur::WebServer::Home.new(root)
          end
        end
        options = {
          app:  app,
          Port: port,
          debug: false
        }
        Rack::Server.start(options)
      end
      
      def open
        require 'launchy'
        url = "http://localhost:#{port}/login?sessionid=#{sessionid}"
        # as launchy sometimes silently fails, we need human-friendly failover
        $stderr.puts "UI should be available now at #{url}" 
        Launchy.open(url)
      end
      
      protected
      
      def port
        @port ||= find_available_port
      end
      
      def find_available_port
        server = TCPServer.new('127.0.0.1', 0)
        server.addr[1]
      ensure
        server.close if server
      end
      
      def sessionid
        require 'securerandom'
        @sessionid ||= SecureRandom.hex(32)
      end
    end
  end
end
