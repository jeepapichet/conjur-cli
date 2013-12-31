require 'conjur/webserver/server'
require 'rack'

include Conjur::WebServer

describe Server do
  let(:port) { 1001 }
  let(:sessionid) { "the-session-id" }
  let(:server) { Server.new }
  
  describe "#start" do
    it "launches a Rack web server" do
      require 'rack'
      Rack::Server.should_receive(:start)
      
      server.start File.dirname(__FILE__)
    end
  end
  
  describe "#open" do
    it "opens a web browser with unique session id" do
      require 'launchy'
  
      server.stub(:find_available_port).and_return port
      server.stub(:sessionid).and_return sessionid
      Launchy.should_receive(:open).with("http://localhost:#{port}/login?sessionid=#{sessionid}")
      
      server.open
    end
  end
end