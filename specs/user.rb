require_relative 'helper/setup'
require_relative '../lib/models/user'
require 'bcrypt'

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
end
