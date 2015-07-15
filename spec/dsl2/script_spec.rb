require 'spec_helper'
require 'conjur/dsl2/script'

describe Conjur::DSL2::Script, dsl2: true  do
  let(:runner) { Conjur::DSL2::Script.new context }
  
  describe '#create' do
    let(:filename) { "create_all.policy" }
    let(:records) { 
      {}.tap do |m|
        %w(user group host layer variable role resource).each do |kind|
          m[kind] = double(kind, annotations: {})
        end
      end
    }
    before {
      %w(user group host layer variable role resource).each do |kind|
        result = records[kind] or raise "No #{kind} record expected"
        expect(api).to receive("create_#{kind}".to_sym).and_return(result)
      end
    }
        
    it "creates all the things" do
      runner.execute
    end
    
    it "populates annotations" do
      runner.execute
      expect(records['user'].annotations).to eq('name' => 'joe')
    end
  end
  
  describe '#create' do
    let(:filename) { "grant_group.policy" }
    it "grants group:developers to user:joe" do
      expect(api).to receive("create_group").with("developers", {})
      expect(api).to receive("create_user").with("joe", {})
      expect(api).to receive("role").with("group:developers").and_return(developers=double(:developers))
      expect(api).to receive("role").with("user:joe").and_return(joe=double(:joe))
      expect(developers).to receive(:grant_to).with(joe)
      runner.execute
    end
  end
end
