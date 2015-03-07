require_relative 'helper/setup'
require_relative '../lib/setup'

describe 'setup' do
  it 'creates a database connection' do
    expect(Logformat::DB.select(1).all).to eql [{:"1"=>1}]
  end

  it 'creates tables' do
    expect(Logformat::DB.table_exists?(:messages)).to be_truthy
    expect(Logformat::DB.table_exists?(:channels)).to be_truthy
  end

  it 'sets the database timezone to UTC' do
    expect(Sequel.database_timezone).to eql :utc
  end

  it 'sets configuration constants' do
    expect(Logformat::IRC_HOST).not_to be_nil
    expect(Logformat::IRC_NICK).not_to be_nil
    expect(Logformat::WEB_PORT).to be_a_kind_of(Fixnum)
  end
end
