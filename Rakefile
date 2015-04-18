namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require_relative 'lib/setup'
    Sequel.extension :migration
    db = Logformat::DB
    migs = File.join(File.dirname(__FILE__),'migrations')
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, migs, target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(db, migs)
    end
  end
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts='--pattern specs/*.rb'
  end
rescue LoadError
end

task :default => :spec
