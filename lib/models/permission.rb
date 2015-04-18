require_relative '../setup'
require_relative 'user'
require_relative 'channel'

module Logformat
  class Permission<Sequel::Model
    many_to_one :user
    many_to_one :channel

    DENY = 0
    ALLOW = 1
    DEFAULT = ALLOW
  end
end
