require_relative '../setup'
require_relative 'channel'

module Logformat
  class Message<Sequel::Model
    many_to_one :channel

    def to_s
      case type
      when 'message'
        "[#{time}] <#{nick}> #{text}"
      when 'action'
        "[#{time}] * #{nick} #{text}"
      when 'nick'
        "[#{time}] #{nick} changed nickname to #{text}"
      when 'join'
        "[#{time}] #{nick} joined"
      when 'leave'
        "[#{time}] #{nick} left: #{text}"
      when 'quit'
        "[#{time}] #{nick} quit: #{text}"
      else
        "[#{time}] #{type}: <#{nick}> #{text}"
      end
    end
  end
end
