#!/usr/bin/env ruby

require_relative '../lib/parser'
require 'parallel'

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
  log_files = Dir.glob(File.join(dir, '????-??-??.log'))
  Parallel.each(log_files) do |file|
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
