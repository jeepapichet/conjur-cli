require 'conjur/webserver/authorize'
require 'rack'

include Conjur::WebServer

describe Authorize do
  let(:app) { double(:app) }
  let(:sessionid) { "the-session-id" }
  let(:authorize) { Authorize.new(app, sessionid) }
  
  describe "#call" do
    context "with a valid token" do
      let(:env) {
        { "rack.session" => { sessionid: sessionid } }
      }
      it "propagates the request" do
        app.should_receive(:call)
        
        authorize.call env
      end
    end
    context "without a valid token" do
      let(:env) {
        { "rack.session" => { "sessionid" => "foobar" } }
      }
      it "responds with error" do
        authorize.call(env)[0].should == 403
      end
    end
  end
end