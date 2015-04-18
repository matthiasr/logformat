require_relative 'helper/setup'

require_relative '../bin/web'
require 'rspec'
require 'rack/test'

describe 'web frontend' do
  RSpec.configure do |conf|
    conf.include Rack::Test::Methods

    # create sample data for each test
    before(:example) do
      c = Logformat::Channel.create(:name => '#testchannel', :slug => 'testchannel')
      t = DateTime.new(2014,10,10,12,34,56,'+2')
      Logformat::Message.create(:channel => c, :nick => 'nickname', :text => 'message 1', :time => t)
    end
  end

  def app
    Sinatra::Application
  end

  describe 'landing page' do
    it 'is served' do
      get '/'

      expect(last_response).to be_ok
    end

    it 'lists channels' do
      get '/'
      expect(last_response).to match(/#testchannel/)
      expect(last_response).to match(/href="http:\/\/example.org\/testchannel"/)
    end
  end

  describe 'channel page' do
    it 'is rendered' do
      get '/testchannel'
      expect(last_response).to be_ok
    end

    it 'has a link to the day with messages' do
      get '/testchannel'
      expect(last_response).to match(/href="http:\/\/example.org\/testchannel\/2014-10-10"/)
    end
  end

  describe 'day page' do
    it 'is rendered' do
      get '/testchannel/2014-10-10'
      expect(last_response).to be_ok
    end

    it 'contains next and previous day links' do
      get '/testchannel/2014-10-10'
      expect(last_response).to match(/href="http:\/\/example.org\/testchannel\/2014-10-09"/)
      expect(last_response).to match(/href="http:\/\/example.org\/testchannel\/2014-10-11"/)
    end

    it 'shows the message' do
      get '/testchannel/2014-10-10'
      expect(last_response).to match(/nickname/)
      expect(last_response).to match(/message 1/)
    end

    it 'does not show the message on a different day' do
      get '/testchannel/2014-10-09'
      expect(last_response).not_to match(/message 1/)
    end
  end
end
