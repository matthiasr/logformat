require_relative '../setup'
require_relative 'channel'

module Logformat
  class Message<Sequel::Model
    many_to_one :channel
  end
end
