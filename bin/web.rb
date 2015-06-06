#!/usr/bin/env ruby

require 'sinatra'
require_relative '../lib/setup'
require_relative '../lib/models/message'
require_relative '../lib/models/channel'
require_relative '../lib/models/user'
include Logformat

set :views, File.join(File.dirname(__FILE__),'..','views')
set :public_folder, File.join(File.dirname(__FILE__),'..','public')
set :port, WEB_PORT
set :bind, WEB_BIND

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def check_channel_access!
    user = User.from_env(request.env)
    channel = Channel.find(:slug => params[:channel])
    if channel.nil?
      halt 404, erb(:error, :locals => {
        :title => 'Logs: Not found',
        :text => 'No such channel',
      })
    else
      if channel.allowed?(user)
        channel
      else
        headers['WWW-Authenticate'] = "Basic realm=\"Logs for #{channel.name}\""
        halt 401
      end
    end
  end

  def parse_date
    begin
      DateTime.strptime(params[:date], '%Y-%m-%d')
    rescue ArgumentError => e
      halt 400, erb(:error, :locals => {
        :title => "Logs: Invalid Date",
        :text => "Invalid date",
      })
    end
  end
end

get '/' do
  content_type :html
  erb :channel_list, :locals => {
    :title => 'Logs',
    :channels => Channel.all,
  }
end

get '/-/whoami' do
  content_type :text
  User.from_env(request.env).name
end

get '/-/health' do
  content_type :text
  'OK'
end

get '/:channel/:date.txt' do
  content_type :txt
  channel = check_channel_access!
  date = parse_date

  channel
    .messages_for_day(date)
    .map { |m| m.to_s }
    .join("\n")
end

get '/:channel/:date' do
  content_type :html
  channel = check_channel_access!

  date = parse_date

  erb :channel, :locals => {
    :title => "Logs for #{channel.name}, #{date.strftime('%Y-%m-%d')}",
    :messages => channel.messages_for_day(date),
    :date => date,
    :channel => channel,
  }
end

# NOTE: this is quite expensive (sequential scan on messages)
get '/:channel' do
  content_type :html
  channel = check_channel_access!
  erb :channel_days, :locals => {
    :title => "Logs for #{channel.name}",
    :channel => channel,
    :days => Message
      .filter(:channel => channel)
      .select(
        Sequel.as(
          Sequel.function(:date, :time),
          :date
        )
      )
      .group(:date)
      .order(Sequel.desc(:date))
      .map(:date)
  }
end
