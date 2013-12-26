require 'conjur/webserver/server'

include Conjur::WebServer

describe Server do
  let(:port) { 1001 }
  let(:sessionid) { "the-session-id" }
  let(:page) { "the/page.html" }
  let(:server) { Server.new }
  
  describe "#start" do
    it "launches a Rack web server" do
      require 'rack'
      Rack::Server.should_receive(:start)
      
      server.start page
    end
    
    it "uses a unique session id"
  end
  
  describe "#open" do
    it "opens a web browser with unique session id" do
      require 'launchy'
  
      server.stub(:find_available_port).and_return port
      server.stub(:sessionid).and_return sessionid
      Launchy.should_receive(:open).with("http://localhost:#{port}/#{page}##{sessionid}")
      
      server.open page
    end
  end
end