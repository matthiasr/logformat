require_relative 'helper/setup'
require_relative '../lib/models/channel'

describe 'channel' do
  it 'can be created' do
    c = Logformat::Channel.create(:name => '#channel', :slug=> 'slug')
    expect(c.id).to eql 1
    expect(c.name).to eql '#channel'
    expect(c.slug).to eql 'slug'
    expect(Logformat::Channel.all.first).to eql c
  end
  it 'automatically generates slug' do
    c = Logformat::Channel.create(:name => '#channel')
    expect(c.slug).to eql 'channel'
    expect(Logformat::Channel.all.first.slug).to eql 'channel'
  end

  it 'allows setting the slug before saving' do
    c1 = Logformat::Channel.new(:name => '#channel')
    c1.slug = 'slug'
    c1.save

    c2 = Logformat::Channel.all.first
    
    expect(c1.slug).to eql 'slug'
    expect(c2.slug).to eql 'slug'
  end

  it 'only allows unique channel names' do
    expect(Logformat::Channel.create(:name => '#channel', :slug => 'channel1').name).to eql '#channel'
    expect{Logformat::Channel.create(:name => '#channel', :slug => 'channel2')}.to raise_error Sequel::UniqueConstraintViolation
  end
  it 'only allows unique channel slugs' do
    expect(Logformat::Channel.create(:name => '#channel1', :slug => 'channel').slug). to eql 'channel'
    expect{Logformat::Channel.create(:name => '#channel2', :slug => 'channel')}.to raise_error Sequel::UniqueConstraintViolation
  end
end
