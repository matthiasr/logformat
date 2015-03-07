#!/usr/bin/env ruby

require 'sinatra'
require_relative '../lib/setup'
require_relative '../lib/models/message'
require_relative '../lib/models/channel'
include Logformat

set :views, File.join(File.dirname(__FILE__),'..','views')
set :public_folder, File.join(File.dirname(__FILE__),'..','public')
set :port, WEB_PORT

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end


get '/' do
  erb :channel_list, :locals => {
    :title => 'Logs',
    :channels => Channel.all,
  }
end

get '/:channel/:date' do
  begin
    date = DateTime.strptime(params[:date], '%Y-%m-%d')
  rescue ArgumentError => e
    status 400
    return erb :error, :locals => {
      :title => "Logs: Invalid Date",
      :text => "Invalid date",
    }
  end

  channel = Channel.find(:slug => params[:channel])
  if channel.nil?
    status 404
    erb :error, :locals => {
      :title => 'Logs: Not found',
      :text => 'No such channel',
    }
  else
    erb :channel, :locals => {
      :title => "Logs for #{channel.name}, #{date.strftime('%Y-%m-%d')}",
      :messages => Message
        .filter(:channel => channel)
        .where(['time BETWEEN ? AND ?', date, date+1])
        .order(:time, :id),
      :date => date,
      :channel => channel,
    }
  end
end

# XXX should be date picker
get '/:channel' do
  status 404
  erb :error, :locals => {
    :title => 'Logs: Not implemented',
    :text => 'There will be a date picker here some day.',
  }
end
