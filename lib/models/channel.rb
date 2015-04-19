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

    def permission(user)
      p = Permission.find(:user => user, :channel => self)
      if p.nil? && user == User.anonymous
        Permission::DEFAULT
      elsif p.nil?
        permission(User.anonymous)
      else
        p.rule
      end
    end

    def allowed?(user)
      permission(user) == Permission::ALLOW
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
