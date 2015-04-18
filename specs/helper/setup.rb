ENV['DB'] = 'sqlite://'
ENV['RACK_ENV'] = 'test'

require_relative '../../lib/setup'
require 'rspec'

RSpec.configure do |c|
  c.around(:each) do |example|
    Logformat::DB.transaction(:rollback=>:always, :auto_savepoint=>true){example.run}
  end
end
