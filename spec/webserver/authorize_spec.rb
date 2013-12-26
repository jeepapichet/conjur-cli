require 'conjur/webserver/middleware/authorize'

include Conjur::WebServer::Middleware

describe Authorize do
  let(:app) { double(:app) }
  let(:sessionid) { "the-session-id" }
  let(:authorize) { Authorize.new(app, sessionid) }
  
  describe "#call" do
    let(:env) {
      {
        'Authorization' => 'the-authorization',
        'X-Foo' => 'x-foo'
      }
    }
    context "with a valid token" do
      before {
        authorize.stub(:token_valid?).and_return true
      }
      
      it "propagates the request" do
        modified_env = env.dup
        modified_env.delete 'Authorization'
        
        app.should_receive(:call).with modified_env
        
        authorize.call env
      end
    end
    context "without a valid token" do
      before {
        authorize.stub(:token_valid?).and_return false
      }
      it "responds with error" do
        authorize.call(env)[0].should == 403
      end
    end
  end
  
  describe "#token_valid?" do
    shared_examples_for "rejects the request" do
      specify {
        authorize.call(env)[0].should == 403
      }
    end
    
    context "with a token" do
      context "which is valid" do
        let(:env) {
          {
            'Authorization' => sessionid
          }
        }
        it "validates the token"
      end
      context "which is invalid" do
        let(:env) {
          {
            'Authorization' => "foobar"
          }
        }
        it_should_behave_like "rejects the request"
      end
    end
    context "without a token" do
      let(:env) {
        {
          'REQUEST_URI' => 'http://localhost'
        }
      }
      it_should_behave_like "rejects the request"
    end
  end
end