require_relative '../setup'
require_relative 'message'

module Logformat
  class Channel<Sequel::Model
    one_to_many :messages

    def before_create
      super
      self.slug ||= self.name[1..-1]
    end
  end
end
