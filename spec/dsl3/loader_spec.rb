require 'spec_helper'
require 'conjur/dsl3/loader'

describe Conjur::DSL3::Loader, dsl3: true  do

  shared_examples_for "round-trip dsl" do |example|
    let(:filename) { "spec/dsl3/#{example}.yml" }
    it "round-trips the DSL" do
      expect(Conjur::DSL3::Loader.load_file(filename).to_yaml).to eq(File.read("spec/dsl3/#{example}.expected.yml"))
    end
  end
  
  it_should_behave_like 'round-trip dsl', 'sequence'
  it_should_behave_like 'round-trip dsl', 'record'
  it_should_behave_like 'round-trip dsl', 'record_members'
  it_should_behave_like 'round-trip dsl', 'permit'
  it_should_behave_like 'round-trip dsl', 'permissions'
  it_should_behave_like 'round-trip dsl', 'deny'
  it_should_behave_like 'round-trip dsl', 'jenkins-policy'
end
