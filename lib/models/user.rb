require_relative '../setup'

module Logformat
  class User<Sequel::Model
    plugin :secure_password

    def self.anonymous
      self.find(:id => 0)
    end
  end
end
