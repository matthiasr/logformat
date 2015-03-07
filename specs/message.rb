require_relative 'helper/setup'
require_relative '../lib/models/message'

describe Logformat::Message do
  it 'can be created with all fields' do
    t = DateTime.now
    Logformat::Message.create(:nick => 'nickname', :text => 'text', :time => t)
    messages = Logformat::Message.all

    expect(messages.size).to eql 1
    m = messages.first
    expect(m.id).to eql 1
    expect(m.nick).to eql 'nickname'
    expect(m.text).to eql 'text'
    # how to match DateTime without pulling in ActiveSupport?
  end

  it 'can be created without time' do
    Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'message')
    messages = Logformat::Message.all

    expect(messages.size).to eql 1
    m = messages.first
    expect(m.id).to eql 1
    expect(m.nick).to eql 'nickname'
    expect(m.text).to eql 'text'
    expect(m.type).to eql 'message'
  end

end
