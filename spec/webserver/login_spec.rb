require 'conjur/webserver/login'

include Conjur::WebServer

describe Login do
  let(:sessionid) { "the-session-id" }
  let(:login) { Login.new(sessionid) }
  
  describe "#call" do
    let(:env) {
      { "rack.session" => {} }
    }
    context "with a valid token" do
      before {
        login.stub(:token_valid?).and_return sessionid
      }
      
      it "propagates the request" do
        login.call env
        
        env["rack.session"][:sessionid].should == sessionid
      end
    end
    context "without a valid token" do
      before {
        login.stub(:token_valid?).and_return false
      }
      it "responds with error" do
        login.call(env)[0].should == 403
        env["rack.session"][:sessionid].should_not be
      end
    end
  end
  
  describe "#token_valid?" do
    shared_examples_for "rejects the request" do
      specify {
        login.call(env)[0].should == 403
      }
    end
    
    context "with a token" do
      context "which is valid" do
        let(:env) {
          { 'REQUEST_URI' => "/login?sessionid=#{sessionid}" }
        }
        it "validates the token" do
          login.send(:token_valid?, env).should == sessionid
        end
      end
      context "which is invalid" do
        let(:env) {
          { 'REQUEST_URI' => '/login?sessionid=foobar' }
        }
        it_should_behave_like "rejects the request"
      end
    end
    context "without a token" do
      let(:env) {
        { 'REQUEST_URI' => 'http://localhost' }
      }
      it_should_behave_like "rejects the request"
    end
  end
end