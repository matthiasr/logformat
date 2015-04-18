require_relative '../setup'
require_relative 'permission'
require 'rack/auth/basic'

module Logformat
  class User<Sequel::Model
    plugin :secure_password

    one_to_many :permission

    def self.anonymous
      self.find(:id => 0)
    end

    def self.from_env(env)
      @auth = Rack::Auth::Basic::Request.new(env)
      u = nil
      if @auth.provided? && @auth.basic?
        candidate = User.find(:name => @auth.username)
        unless candidate.nil? || candidate == User.anonymous
          u = candidate.authenticate(@auth.credentials[1])
        end
      end
      u || User.anonymous
    end
  end
end
