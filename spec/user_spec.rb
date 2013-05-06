require 'helper'

describe Buffer::User do

  describe 'new' do

    it 'accepts a token' do
      user = Buffer::User.new 'some_token'
      user.token.should eq('some_token')
    end

    it 'rejects an integer token' do
      lambda { user = Buffer::User.new 123 }.should raise_error
    end

    it 'rejects an array token' do
      lambda { user = Buffer::User.new [123, 'hello'] }.should raise_error
    end

    it 'rejects an hash token' do
      lambda { user = Buffer::User.new :test => 123 }.should raise_error
    end

  end

  describe 'helpers' do

    subject do
      Buffer::User.new 'some_token'
    end

    before do
      stub_get('user.json').
        with(:query => {:access_token => 'some_token'}).
        to_return(
          :body => fixture('user.json'),
          :headers => {:content_type => 'application/json; charset=utf-8'})
    end

    it 'respond with correct id' do
      subject.id.should eq('1234')
    end

    it 'do not respond to eye_color' do
      lambda { color = subject.eye_color }.should raise_error
    end

    it 'respond to get' do
      lambda { user = subject.get 'user' }.should_not raise_error
    end

  end

  describe 'cache' do

    subject do
      Buffer::User.new 'some_token'
    end

    before do
      stub_get('user.json').
        with(:query => {:access_token => 'some_token'}).
        to_return(
          :body => fixture('user.json'),
          :headers => {:content_type => 'application/json; charset=utf-8'})
    end

    describe 'access' do

      before do
        subject.id
      end

      it 'is used after accessing id once' do
        id = subject.id
        a_get('user.json').
          should_not have_been_made
      end

    end

    describe 'invalidation' do

      before do
        subject.id
      end

      it 'forces server access' do
        subject.invalidate
        id = subject.id
        a_get('user.json').
          with(:query => {:access_token => 'some_token'}).
          should have_been_made.times(2)
      end

    end

  end

end
