require 'spec_helper'
require 'conjur/dsl/yaml_runner'

include Conjur::DSL

describe YAMLRunner do
  subject { YAMLRunner.new source }
  let(:source) { yaml }

  describe "parsing" do
    describe "demo factory" do
      let(:yaml) {
        <<-YAML
- !policy
  id: demo-factory
  version: 1.0

- &secrets
  - !variable aws/access_key_id
  - !variable aws/secret_access_key
  - !variable aws/topic/arn
  - !variable aws/queue/arn
  - !variable ec2/private_key

- !webservice
  id: service
  permissions:
    ? [execute, read] : *secrets      
        YAML
      }
      
      it "loads the YAML" do
        expect(subject).to be
      end
      it "has expected types" do
        [
          YAMLPolicy,
          Array,
          YAMLWebService,
        ].each_with_index do |type, idx|
          expect(subject.doc[idx]).to be_instance_of(type)
        end
      end
      it "has expected contained types" do
        expect(subject.doc[1][0]).to be_instance_of(YAMLVariable)
        expect(subject.doc[1].length).to eq(5)
      end
      it "loads webservice permissions properly" do
        expect(subject.doc[2].permissions).to be
        expect(subject.doc[2].permissions).to be_instance_of(Hash)
        expect(subject.doc[2].permissions.length).to eq(1)
        expect(subject.doc[2].permissions.keys[0]).to eq(%w(execute read))
        expect(subject.doc[2].permissions.values[0]).to be_instance_of(Array)
        expect(subject.doc[2].permissions.values[0][0]).to be_instance_of(YAMLVariable)
      end
    end
  end
  
  describe "processing" do
    describe "policy" do
      let(:yaml) {
        <<-YAML
- !policy
  id: demo-factory
  version: 1.0
  YAML
      }
      let(:runner) { double(:runner) }
      it "creates the policy" do
        expect(runner).to receive(:policy).with('demo-factory-1.0').and_yield
        
        subject.perform runner
      end
    end
    describe "policy with nesting" do
      let(:yaml) {
        <<-YAML
- !policy
  id: demo-factory
  version: 1.0
  owns:
    - !group
      id: test-group
  YAML
      }
      let(:runner) { double(:runner) }
      it "creates the policy" do
        expect(runner).to receive(:policy).with('demo-factory-1.0').and_yield
        expect(runner).to receive(:group).with('test-group').and_yield
        
        subject.perform runner
      end
    end
  end
end
