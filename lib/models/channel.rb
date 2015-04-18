require_relative '../setup'
require_relative 'message'
require_relative 'permission'

module Logformat
  class Channel<Sequel::Model
    one_to_many :message
    one_to_many :permission

    def before_create
      super
      self.slug ||= self.name[1..-1]
    end

    def allowed?(user)
      p = Permission.find(:user => user, :channel => self)
      if p.nil?
        Permission::DEFAULT == Permission::ALLOW
      else
        p.rule == Permission::ALLOW
      end
    end

    def deny!(user)
      Permission.create(:channel => self, :user => user, :rule => Permission::DENY)
    end

    def deny_anonymous!
      deny!(User.anonymous)
    end

    def allow!(user)
      Permission.create(:channel => self, :user => user, :rule => Permission::ALLOW)
    end

    def allow_anonymous!
      allow!(User.anonymous)
    end
  end
end
