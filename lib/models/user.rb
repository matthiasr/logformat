require_relative '../setup'
require 'rack/auth/basic'

module Logformat
  class User<Sequel::Model
    plugin :secure_password

    def self.anonymous
      self.find(:id => 0)
    end

    def self.from_env(env)
      @auth = Rack::Auth::Basic::Request.new(env)
      u = nil
      if @auth.provided? && @auth.basic?
        candidate = User.find(:name => @auth.username)
        unless candidate.nil?
          u = candidate.authenticate(@auth.credentials[1])
        end
      end
      u || User.anonymous
    end
  end
end
