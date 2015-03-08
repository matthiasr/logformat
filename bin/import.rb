#!/usr/bin/env ruby

require_relative '../lib/parser'

include Logformat

Sequel.application_timezone = :local

if ARGV.size != 1
  puts "Usage: import.rb logs/irssi/network"
  exit 1
end

basedir = ARGV[0]

channel_dirs = Dir.glob(File.join(basedir, '#*'))

channel_dirs.each do |dir|
  channel_name = File.basename(dir)
  Channel.find_or_create(:name => channel_name)

  log_files = Dir.glob(File.join(dir, '????-??-??.log'))
  log_files.each_slice(log_files.length/8) do |slice|
    print '.'
    Thread.new do
      slice.each do |file|
        DB.transaction do
          day = File.basename(file, '.log')
          File.open(file).each do |line|
            m = Logformat::Message.parse_irssi_line(day, channel_name, line)
            print m.type[0] unless m.nil?
          end
        end
        puts ''
      end
    end
  end
end

# join all threads
Thread.list.each do |t|
  t.join unless t == Thread.current
end
