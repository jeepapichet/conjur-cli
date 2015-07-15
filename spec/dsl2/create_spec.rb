require 'spec_helper'
require 'conjur/dsl2/create'

describe Conjur::DSL2::Create, dsl2: true  do
  subject { Conjur::DSL2::Create.new(context) }
  it 'knows how to create a user' do
    expect(subject).to respond_to(:user)
  end
  it 'propagates create_user arguments' do
    login = 'the-login'
    options = { foo: 12 }
    expect(api).to receive(:create_user).with(login, options)
    subject.user login, options
  end
  it 'handles host creation' do
    id = 'the-host'
    options = { foo: 12 }
    expect(api).to receive(:create_host).with(options.merge(id: id))
    subject.host id, options
  end
  it 'handles variable creation without mime_type or kind' do
    id = 'the-variable'
    options = { foo: 12 }
    expect(api).to receive(:create_variable).with(nil, nil, options.merge(id: id))
    subject.variable id, options
  end
  it 'handles variable creation with mime_type and kind' do
    id = 'the-variable'
    options = { foo: 12, mime_type: 'text/plain', kind: 'secret'}
    expect(api).to receive(:create_variable).with('text/plain', 'secret', options.slice(:foo).merge(id: id))
    subject.variable id, options
  end
end
