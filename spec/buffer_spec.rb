require 'helper'

describe 'Buffer::Profiles' do

  describe 'new' do

    it 'accepts a token' do
      user = Buffer::Profiles.new 'some_token'
      user.token.should eq('some_token')
    end

    it 'rejects an integer token' do
      lambda { user = Buffer::Profiles.new 123 }.should raise_error
    end

    it 'rejects an array token' do
      lambda { user = Buffer::Profiles.new [123, 'hello'] }.should raise_error
    end

    it 'rejects an hash token' do
      lambda { user = Buffer::Profiles.new :test => 123 }.should raise_error
    end

  end
end
