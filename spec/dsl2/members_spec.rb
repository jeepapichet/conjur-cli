require 'spec_helper'
require 'conjur/dsl2/grant'
require 'conjur/dsl2/revoke'

describe Conjur::DSL2::Grant, dsl2: true  do
  subject { Conjur::DSL2::Grant.new(context) }
  it 'knows how to add a group member' do
    expect(subject).to respond_to(:group)
  end
  it 'builds group.role.grant_to arguments' do
    expect(api).to receive(:role).with('group:developers').and_return(developers = double(:developers))
    expect(api).to receive(:role).with('user:alice').and_return(alice=double(:alice))
    expect(developers).to receive(:grant_to).with(alice)
    subject.group "developers", "user:alice"
  end
  it 'knows how to add a role member' do
    expect(subject).to respond_to(:role)
  end
  it 'builds role.grant_to arguments' do
    expect(api).to receive(:role).with('group:developers').and_return(developers = double(:developers))
    expect(api).to receive(:role).with('user:alice').and_return(alice=double(:alice))
    expect(developers).to receive(:grant_to).with(alice)
    subject.role "group:developers", "user:alice"
  end
end

describe Conjur::DSL2::Revoke, dsl2: true  do
  subject { Conjur::DSL2::Revoke.new(context) }
  it 'knows how to remove a group member' do
    expect(subject).to respond_to(:group)
  end
  it 'builds group.role.revoke_from arguments' do
    expect(api).to receive(:role).with('group:developers').and_return(developers = double(:developers))
    expect(api).to receive(:role).with('user:alice').and_return(alice=double(:alice))
    expect(developers).to receive(:revoke_from).with(alice)
    subject.group "developers", "user:alice"
  end
  it 'knows how to remove a role member' do
    expect(subject).to respond_to(:role)
  end
  it 'builds role.grant_to arguments' do
    expect(api).to receive(:role).with('group:developers').and_return(developers = double(:developers))
    expect(api).to receive(:role).with('user:alice').and_return(alice=double(:alice))
    expect(developers).to receive(:revoke_from).with(alice)
    subject.role "group:developers", "user:alice"
  end
end
