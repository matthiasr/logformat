require 'sequel'

module Logformat
  Sequel.default_timezone = :utc
  DB = Sequel.connect(ENV['DB'] || 'sqlite://local.db', :max_connections => 100)

  unless DB.table_exists?(:messages)
    Sequel.extension :migration
    Sequel::Migrator.run(DB, File.join(File.dirname(__FILE__),'..','migrations'))
  end

  IRC_HOST = ENV['SERVER'] || 'irc.freenode.net'
  IRC_NICK = ENV['NICK'] || 'logformat'

  WEB_PORT = ENV['PORT'] || 8080
end
