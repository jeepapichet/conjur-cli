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
        require 'conjur/webserver/middleware/authorize'
        require 'conjur/webserver/middleware/api_proxy'
        
        sessionid = self.sessionid
        app = Rack::Builder.new do
          use Conjur::WebServer::Middleware::Authorize, sessionid
          use Conjur::WebServer::Middleware::APIProxy
          use Rack::Static, urls: "", root: root
        end
        options = {
          app: app,
          port: port
        }
        Rack::Server.start(options)
      end
      
      def open(page)
        require 'launchy'
        url = [ URI.join("http://localhost:#{port}", page).to_s, sessionid ].join("#")
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
        @sessionid ||= SecureRandom.hex(32)
      end
    end
  end
end