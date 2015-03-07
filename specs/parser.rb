require_relative 'helper/setup'
require_relative '../lib/parser'

describe 'Log parser' do

  it 'raises an exception on an invalid line' do
    expect{Logformat::Message.parse_irssi_line('2016-10-15','#somechannel','< alice> Man darf nicht in verpassen denken.')}.to raise_error ArgumentError
    expect(Logformat::Message.count).to eql 0
  end
  
  it 'parses a normal message line' do
    m = Logformat::Message.parse_irssi_line('2016-10-15','#somechannel','01:42 < alice> Man darf nicht in verpassen denken.')
    expect(m.type).to eql 'message'
    expect(m.channel.name).to eql '#somechannel'
    expect(m.nick).to eql 'alice'
    expect(m.text).to eql 'Man darf nicht in verpassen denken.'
    # FIXME: figure out how to deal with timezones at time of logging, instead of assuming UTC
    expect(m.time).to eql Time.new(2016,10,15,01,42,0,'+00:00') 

    expect(Logformat::Message.all).to eql [m]
  end

  it 'parses a message by an operator' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '12:10 <@alice> weder noch')
    expect(m.type).to eql 'message'
    expect(m.nick).to eql 'alice'
    expect(m.text).to eql 'weder noch'
  end

  it 'parses a join' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '01:25 bob (~bo@example.com) has joined #somechannel')
    expect(m.type).to eql 'join'
    expect(m.nick).to eql 'bob'
    expect(m.text).to eql ''
  end

  it 'parses a quit' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '01:30  bob (~bo@example.com) has quit (Ping timeout: 240 seconds)')
    expect(m.type).to eql 'quit'
    expect(m.nick).to eql 'bob'
    expect(m.text).to eql 'Ping timeout: 240 seconds'
  end

  it 'accepts quit with -!-' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '22:04 -!- henry [n=henry@1.2.3.4] has quit [Remote closed the connection]')

    expect(m.type).to eql 'quit'
    expect(m.nick).to eql 'henry'
    expect(m.text).to eql 'Remote closed the connection'
  end

  it 'parses a leave' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '12:11  eve (~eve@example.com) has left #somechannel ()')
    expect(m.type).to eql 'leave'
    expect(m.nick).to eql 'eve'
  end

  it 'parses a nick change' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '02:29  alice is now known as alice[ZzZz]')
    expect(m.type).to eql 'nick'
    expect(m.nick).to eql 'alice'
    expect(m.text).to eql 'alice[ZzZz]'
  end

  it 'parses an action' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '17:49  * harry wirft Glitzer herum')
    expect(m.type).to eql 'action'
    expect(m.nick).to eql 'harry'
    expect(m.text).to eql 'wirft Glitzer herum'
  end

  it 'parses a kick' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '11:29  eve was kicked from #somechannel by alice (Genug.)')
    expect(m.type).to eql 'kick'
    expect(m.nick).to eql 'eve'
    expect(m.text).to eql 'alice'
  end

  it 'parses a topic change' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '18:57  alice changed the topic of #somechannel to: Dieser Kanal ist jetzt UTF-8.')
    expect(m.type).to eql 'topic'
    expect(m.nick).to eql 'alice'
    expect(m.text).to eql 'Dieser Kanal ist jetzt UTF-8.'
  end

  it 'parses a notice' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '17:28 -thebot|#somechannel- 15 Sekunden Vetophase läuft.')
    expect(m.type).to eql 'notice'
    expect(m.nick).to eql 'thebot'
    expect(m.text).to eql '15 Sekunden Vetophase läuft.'
  end

  it 'parses a server notice' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '13:42 -cameron.freenode.net- [freenode-info] channel trolls and no channel staff around to help? please check with freenode support: http://freenode.net/faq.shtml#gettinghelp')
    expect(m.type).to eql 'notice'
    expect(m.nick).to eql 'cameron.freenode.net'
    expect(m.text).to eql '[freenode-info] channel trolls and no channel staff around to help? please check with freenode support: http://freenode.net/faq.shtml#gettinghelp'
  end

  it 'ignores opening' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '--- Log opened Sat Oct 15 00:00:53 2016')
    expect(m).to be_nil
    expect(Logformat::Message.count).to eql 0
  end

  it 'ignores own nick change' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '22:33  You\'re now known as logbot')
    expect(m).to be_nil
    expect(Logformat::Message.count).to eql 0
  end

  it 'accepts changing to nicks starting with digits' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '16:46  some_nick is now known as 1nick')
    expect(m.type).to eql 'nick'
    expect(m.nick).to eql 'some_nick'
    expect(m.text).to eql '1nick'
  end

  it 'accepts changing from nicks starting with digits' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '16:47  1nick is now known as some_nick')
    expect(m.type).to eql 'nick'
    expect(m.nick).to eql '1nick'
    expect(m.text).to eql 'some_nick'
  end

  it 'accepts nick starting with digits for messages' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '23:42 < 1nick> text')
    expect(m.type).to eql 'message'
    expect(m.nick).to eql '1nick'
    expect(m.text).to eql 'text'
  end

  it 'accepts nick starting with digits for actions' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '23:42  * 1nick text')
    expect(m.type).to eql 'action'
    expect(m.nick).to eql '1nick'
    expect(m.text).to eql 'text'
  end

  it 'accepts topic changes by the server' do
    m = Logformat::Message.parse_irssi_line('2016-10-15', '#somechannel', '03:11  irc.example.com changed the topic of #somechannel to: the topic')
    expect(m.type).to eql 'topic'
    expect(m.nick).to eql 'irc.example.com'
    expect(m.text).to eql 'the topic'
  end
end
