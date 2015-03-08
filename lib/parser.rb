require_relative 'models/message'
require_relative 'models/channel'

module Logformat
  class Message
    # day: string in format "YYYY-MM-DD"
    def self.parse_irssi_line(day, channel_name, line)
      line_regex = /^([012][0-9]:[0-6][0-9]) <[ @]*([^>]+)> (.*)$/
      action_regex = /^([012][0-9]:[0-6][0-9]) +\* +([a-z0-9_\-\[\]\\^{}|`]+) (.*)$/i
      join_regex = /^([012][0-9]:[0-6][0-9]) (?:-!-)? ?([a-z0-9_\-\[\]\\^{}|`]+) [\[(].*[\])] has joined /i
      quit_regex = /^([012][0-9]:[0-6][0-9]) (?:-!-)? ?([a-z0-9_\-\[\]\\^{}|`]+) [\[(].*[\])] has quit [\[(](.*)[\])]$/i
      leave_regex = /^([012][0-9]:[0-6][0-9]) +([a-z0-9_\-\[\]\\^{}|`]+) \(.*\) has left (?:[#&][^\x07\x2C\s]+) \((.*)\)$/i
      kick_regex = /^([012][0-9]:[0-6][0-9]) +([a-z0-9_\-\[\]\\^{}|`]+) was kicked from (?:[#&][^\x07\x2C\s]+) by (?:([a-z0-9_\-\[\]\\^{}|`]+)) \((.*)\)$/i
      nickchange_regex = /^([012][0-9]:[0-6][0-9]) (?:-!-)? ?([a-z0-9_\-\[\]\\^{}|`]+) is now known as ([a-z0-9_\-\[\]\\^{}|`]+)/i
      notice_regex = /^([012][0-9]:[0-6][0-9]) -([a-z0-9_\-\[\]\\^{}|`.]+)(?:\|[#&][^\x07\x2C\s]+)?- (.*)$/i
      topic_regex = /^([012][0-9]:[0-6][0-9]) +([a-z0-9_\-\[\]\\^{}|`.]+) changed the topic of [#&][^\x07\x2C\s]+ to: (.*)$/i
      ignore_regex = /(?:^--- |^([012][0-9]:[0-6][0-9]) +(?:Irssi:|Netsplit|mode\/|ServerMode\/|You're now known as))/


      unless line.valid_encoding?
        line = line.force_encoding('iso-8859-1').encode('utf-8')
      end
      case line
      when line_regex
        time = $1
        nick = $2
        text = $3
        type = :message
      when action_regex
        time = $1
        nick = $2
        text = $3
        type = :action
      when join_regex
        time = $1
        nick = $2
        text = ""
        type = :join
      when quit_regex
        time = $1
        nick = $2
        text = $3
        type = :quit
      when leave_regex
        time = $1
        nick = $2
        text = $3
        type = :leave
      when kick_regex
        time = $1
        nick = $2
        text = $3
        type = :kick
      when nickchange_regex
        time = $1
        nick = $2
        text = $3 # text == new nick
        type = :nick
      when notice_regex
        time = $1
        nick = $2
        text = $3
        type = :notice
      when topic_regex
        time = $1
        nick = $2
        text = $3
        type = :topic
      when ignore_regex
        return nil
      else
        raise(ArgumentError, "Invalid line at #{channel_name}, #{day}: #{line}")
      end

      # FIXME: DateTime assumes UTC, so all times will be interpreted as such
      # SHOULD BE: Berlin time at the time of logging (take DST into account if possible)
      dt = DateTime.new(*day.split('-').map{|s| s.to_i}, *time.split(':').map{|s| s.to_i})
      channel = Channel.find_or_create(:name => channel_name).freeze
      Message.find_or_create(:time => dt, :nick => nick, :text => text, :channel => channel, :type => type.to_s).freeze
    end
  end
end
