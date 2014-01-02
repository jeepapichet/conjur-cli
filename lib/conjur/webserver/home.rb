require 'time'
require 'rack/utils'
require 'rack/mime'

module Conjur
  module WebServer
    class Home
      F = ::File
      
      def initialize(root)
        @root = root
      end
      
      # From Rack::File
      def call(env)
        path = File.expand_path("index.html", @root)

        if env["REQUEST_METHOD"] == "OPTIONS"
                return [200, {'Allow' => ALLOW_HEADER, 'Content-Length' => '0'}, []]
        end
        last_modified = F.mtime(path).httpdate
        return [304, {}, []] if env['HTTP_IF_MODIFIED_SINCE'] == last_modified

        size = F.size?(path) || Rack::Utils.bytesize(F.read(path))
  
        headers = { 
          "Last-Modified"  => last_modified,
          "Content-Type"   => "text/html",
          "Content-Length" => size.to_s
        }
  
        [ 200, headers, env["REQUEST_METHOD"] == "HEAD" ? [] : [ F.read(path) ] ]
      end
    end
  end
end
