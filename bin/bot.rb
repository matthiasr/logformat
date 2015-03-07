#!/usr/bin/env ruby

require 'cinch'
require_relative '../lib/models/channel'
require_relative '../lib/models/message'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = Logformat::IRC_HOST
    c.nick = Logformat::IRC_NICK
    c.channels = Logformat::Channel.filter(:join => true).map { |c| c.name }
  end

  helpers do
    def converge_channels
      configured_channels = Logformat::Channel.filter(:join => true).map { |c| c.name }
      current_channels = bot.channels.map { |c| c.name }
      (configured_channels - current_channels).each do |c|
        bot.channel_list.find_ensured(c).join
      end
      (current_channels - configured_channels).each do |c|
        bot.channel_list.find(c).part
      end
    end

    def save_message(type,user,text,channel_name)
      chan = Logformat::Channel.find_or_create(:name => channel_name)
      Logformat::Message.insert(:channel_id => chan.id, :nick => user, :text => text, :type => type.to_s)
      converge_channels
    end
  end

  on :message do |m|
    save_message(:message, m.user.nick, m.message, m.channel.name) unless m.action?
  end

  on :action do |m|
    save_message(:action, m.user.nick, m.action_message, m.channel.name)
  end

  on :part do |m, user|
    save_message(:leave, user.nick, m.message, m.channel.name)
  end

  on :kick do |m, user|
    save_message(:kick, user.nick, m.message, m.channel.name)
  end

  on :quit do |m, user|
    bot.channels.each do |c|
      save_message(:quit, user.nick, m.message, c.name) if c.has_user?(user)
    end
  end

  on :join do |m|
    save_message(:join, m.user.nick, '', m.channel.name)
  end

  on :nick do |m|
    bot.channels.each do |c|
      save_message(:nick, m.user.last_nick, m.user.nick, c.name) if c.has_user?(m.user)
    end
  end

  on :invite do |m|
    chan = Logformat::Channel.find_or_create(:name => m.channel.name)
    chan.join = true
    chan.save
    converge_channels
  end
end

bot.start
