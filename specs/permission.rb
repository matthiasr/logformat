require_relative 'helper/setup'
require_relative '../lib/models/permission'

require 'rspec'

describe Logformat::Permission do
  include Logformat

  RSpec.configure do |config|
    before(:example) do
      load File.join(File.dirname(__FILE__), 'helper/authmatrix.rb')
    end
  end

  it 'allows creating new permissions' do
    u1 = User.find(:name => 'user1')
    c1 = Channel.find(:name => '#channel1')
    p = Permission.create(:user => u1, :channel => c1, :rule => Permission::DEFAULT)
    expect(p.rule).to eql Permission::ALLOW
  end

  it 'refuses duplicate permissions' do
    u1 = User.find(:name => 'user1')
    c2 = Channel.find(:name => '#channel2')
    expect{Permission.create(:user => u1, :channel => c2)}.to raise_error Sequel::UniqueConstraintViolation
  end

  it 'refuses permissions for nonexistent channels' do
    u1 = User.find(:name => 'user1')
    expect{Permission.create(:user => u1, :channel_id => 12345)}.to raise_error Sequel::ForeignKeyConstraintViolation
  end

  it 'refuses permissions for nonexistent users' do
    c1 = Channel.find(:name => '#channel1')
    expect{Permission.create(:user_id => 12345, :channel => c1)}.to raise_error Sequel::ForeignKeyConstraintViolation
  end
end
