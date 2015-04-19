require_relative 'helper/setup'
require_relative '../lib/models/message'

describe Logformat::Message do
  let(:t) { DateTime.new(2014,10,10,12,34,56,'+7') }

  it 'can be created with all fields' do
    Logformat::Message.create(:nick => 'nickname', :text => 'text', :time => t)
    messages = Logformat::Message.all

    expect(messages.size).to eql 1
    m = messages.first
    expect(m.id).to eql 1
    expect(m.nick).to eql 'nickname'
    expect(m.text).to eql 'text'
    expect(m.time.to_s).to eql '2014-10-10 05:34:56 UTC'
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

  describe 'text representation' do
    it 'of a message' do
      m = Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'message', :time => t)
      expect(m.to_s).to eql '[2014-10-10 05:34:56 UTC] <nickname> text'
    end

    it 'of an action' do
      m = Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'action', :time => t)
      expect(m.to_s).to eql '[2014-10-10 05:34:56 UTC] * nickname text'
    end

    it 'of a nick change' do
      m = Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'nick', :time => t)
      expect(m.to_s).to eql '[2014-10-10 05:34:56 UTC] nickname changed nickname to text'
    end

    it 'of a notice' do
      m = Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'notice', :time => t)
      expect(m.to_s).to eql '[2014-10-10 05:34:56 UTC] notice: <nickname> text'
    end

    it 'of a join' do
      m = Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'join', :time => t)
      expect(m.to_s).to eql '[2014-10-10 05:34:56 UTC] nickname joined'
    end

    it 'of a leave' do
      m = Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'leave', :time => t)
      expect(m.to_s).to eql '[2014-10-10 05:34:56 UTC] nickname left: text'
    end

    it 'of a quit' do
      m = Logformat::Message.create(:nick => 'nickname', :text => 'text', :type => 'quit', :time => t)
      expect(m.to_s).to eql '[2014-10-10 05:34:56 UTC] nickname quit: text'
    end
  end
end
