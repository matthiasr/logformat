#!/usr/bin/env ruby

require_relative '../lib/models/message'

include Logformat

Message.order(:time).each do |m|
  puts "[#{m.channel.name}]#{m}"
end
