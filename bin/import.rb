#!/usr/bin/env ruby

require_relative '../lib/parser'

include Logformat

Sequel.application_timezone = :local

THREADS=1

if ARGV.size != 1
  puts "Usage: import.rb logs/irssi/network"
  exit 1
end

basedir = ARGV[0]

channel_dirs = Dir.glob(File.join(basedir, '*'))

channel_dirs.each do |dir|
  channel_name = '#' + File.basename(dir)
  Channel.find_or_create(:name => channel_name)

  log_files = Dir.glob(File.join(dir, '????-??-??.log')).sort
  log_files.each_slice(log_files.length/THREADS) do |slice|
    Thread.new do
      slice.each do |file|
        DB.transaction do
          day = File.basename(file, '.log')
          puts "#{channel_name} #{day}"
          File.open(file).each do |line|
            m = Logformat::Message.parse_irssi_line(day, channel_name, line)
          end
        end
      end
    end
  end
end

# join all threads
Thread.list.each do |t|
  t.join unless t == Thread.current
end
