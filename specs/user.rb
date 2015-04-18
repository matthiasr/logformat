require_relative 'helper/setup'
require_relative '../lib/models/user'
require 'bcrypt'
require 'base64'

describe Logformat::User do
  it 'has an anonymous user' do
    u = User.anonymous
    expect(u.id).to eql 0
    expect(u.name).to eql 'anonymous'
    expect{u.authenticate('foo')}.to raise_error(BCrypt::Errors::InvalidHash)
  end

  it 'can create users' do
    u = User.create(:name => 'testuser', :password => 'pass', :password_confirmation => 'pass')

    expect(u.name).to eql 'testuser'
    expect(u.authenticate('pass')).to eql u
    expect(u.authenticate('dunno')).to be_nil
  end

  describe 'authentication' do
    RSpec.configure do |conf|
      before(:example) do
        User.create(:name => 'testuser', :password => 'testpass', :password_confirmation => 'testpass')
      end
    end

    it 'returns anonymous on unauthenticated requests' do
      expect(User.from_env({})).to eql User.anonymous
    end

    it 'returns the user on authenticated requests' do
      expect(User.from_env({ 'HTTP_AUTHORIZATION' => 'Basic ' + Base64.encode64('testuser:testpass').chomp })).to eql User.find(:name => 'testuser')
    end

    it 'returns anonymous on requests with wrong password' do
      expect(User.from_env({ 'HTTP_AUTHORIZATION' => 'Basic ' + Base64.encode64('testuser:wrongpass').chomp })).to eql User.anonymous
    end

    it 'returns anonymous on requests with unknown user' do
      expect(User.from_env({ 'HTTP_AUTHORIZATION' => 'Basic ' + Base64.encode64('otheruser:anypass').chomp })).to eql User.anonymous
    end

  end
end
