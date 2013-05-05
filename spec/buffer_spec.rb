require 'helper'

describe Buffer::Client do
  
  describe 'new' do

    it 'accepts a token' do
      client = Buffer::Client.new 'some_token'
      client.token.should eq('some_token')
    end

    it 'rejects an integer token' do
      lambda { client = Buffer::Client.new 123 }.should raise_error(Buffer::InvalidToken)
    end

    it 'rejects an array token' do
      lambda { client = Buffer::Client.new [123, 'hello'] }.should raise_error(Buffer::InvalidToken)
    end

    it 'rejects an hash token' do
      lambda { client = Buffer::Client.new :test => 123 }.should raise_error(Buffer::InvalidToken)
    end

  end

  describe 'api' do

    subject do
      Buffer::Client.new 'some_token'
    end

    it 'is a method' do
      subject.respond_to?(:api).should be_true
    end

    describe 'api :get' do

      before do
        stub_get('user.json').
          with(:query => {:access_token => 'some_token'}).
          to_return(
            :body => fixture('user.json'),
            :headers => {:content_type => 'application/json; charset=utf-8'})

        stub_get('non_existent.json').
          with(:query => {:access_token => 'some_token'}).
          to_return(
            :body => '',
            :headers => {:content_type => 'application/json; charset=utf-8'})

        stub_get('mangled.json').
          with(:query => {:access_token => 'some_token'}).
          to_return(
            :body => '{dfpl:[}233]',
            :headers => {:content_type => 'application/json; charset=utf-8'})
      end

      it 'makes correct request to user.json with access token' do
        subject.api :get, 'user.json'
        a_get('user.json').
          with(:query => {:access_token => 'some_token'}).
          should have_been_made
      end

      it 'makes correct request when passed user' do
        subject.api :get, 'user'
        a_get('user.json').
          with(:query => {:access_token => 'some_token'}).
          should have_been_made
      end

      it 'returns correct parsed object' do
        res = subject.api :get, 'user'
        target = begin
          MultiJson.load fixture('user.json')
        end
        res.should eq(target)
      end

      it 'returns nil from non existent endpoint' do
        res = subject.api :get, 'non_existent'
        res.should eq(nil)
      end

      it 'returns nil from mangled data' do
        res = subject.api :get, 'mangled'
        res.should eq(nil)
      end

    end

    describe 'api :post' do

      before do
        stub_post('updates/create.json').
          with(
            :query => {:access_token => 'some_token'},
            :body => {
              "media"=>{"link"=>"http://google.com"},
              "profile_ids"=>[
                "4eb854340acb04e870000010",
                "4eb9276e0acb04bb81000067"],
              "text"=>"This is an example update"}).
          to_return(
            :body => fixture('success.json'),
            :status => 200)

        stub_post('updates/creatify.json').
          with(
            :query => {:access_token => 'some_token'},
            :body => {
              "media"=>{"link"=>"http://google.com"},
              "profile_ids"=>[
                "4eb854340acb04e870000010",
                "4eb9276e0acb04bb81000067"], 
              "text"=>"This is an example update"}).
          to_return(
            :status => 200)

        stub_request(
          :post,
          "https://api.bufferapp.com/1/updates/create.json?access_token=some_token").
          with(:body => {"profile_ids"=>["fdf", "1"], "text"=>["a237623", "asb"]},
              :headers => {
                'Accept'=>'*/*',
                'Content-Type'=>'application/x-www-form-urlencoded',
                'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it 'should make the correct POST to updates/create.json' do
        subject.api :post,
                    'updates/create.json',
                    :text => "This is an example update",
                    :profile_ids => [
                      '4eb854340acb04e870000010',
                      '4eb9276e0acb04bb81000067'],
                    :media => {:link => "http://google.com"}
        a_post('updates/create.json').
          with(
            :query => {:access_token => 'some_token'},
            :body => fixture_contents('create_body.txt')).
          should have_been_made
      end

      it 'should return a correctly parsed object' do
        res = subject.api :post,
                          'updates/create.json',
                          :text => "This is an example update",
                          :profile_ids => [
                            '4eb854340acb04e870000010',
                            '4eb9276e0acb04bb81000067'],
                          :media => {:link => "http://google.com"}
        res['success'].should be_true
      end

      it 'should return nil from non existent endpoint' do
        res = subject.api :post,
                          'updates/creatify.json',
                          :text => "This is an example update",
                          :profile_ids => [
                            '4eb854340acb04e870000010',
                            '4eb9276e0acb04bb81000067'],
                          :media => {:link => "http://google.com"}
        res.should eq(nil)
      end

      it 'should return nil when passes crap' do
        stub_request(:post, "https://api.bufferapp.com/1/updates/create.json?access_token=some_token").
                 with(:body => {"profile_ids"=>["fdf", "1"], "text"=>["a237623", "asb"]},
                      :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.8.7'}).
                 to_return(:status => 200, :body => "", :headers => {})

        res = subject.api :post,
                          'updates/create.json',
                          :text => [:a237623, 'asb'],
                          :profile_ids => ['fdf', '1']
        res.should eq(nil)
      end

    end

  end

  describe 'get' do

    subject do
      Buffer::Client.new 'some_token'
    end

    it 'is a method' do
      subject.respond_to?(:get).should be_true
    end

    before do
      stub_get('user.json').
        with(:query => {:access_token => 'some_token'}).
        to_return(
          :body => fixture('user.json'),
          :headers => {:content_type => 'application/json; charset=utf-8'})
    end

    it 'makes correct request to user.json with access token' do
      subject.get 'user.json'
      a_get('user.json').
        with(:query => {:access_token => 'some_token'}).
        should have_been_made
    end

    it 'makes correct request when passed user' do
      subject.get 'user'
      a_get('user.json').
        with(:query => {:access_token => 'some_token'}).
        should have_been_made
    end

  end

  describe 'post' do

    subject do
      Buffer::Client.new 'some_token'
    end

    it 'is a method' do
      subject.respond_to?(:post).should be_true
    end

    before do
      stub_post('updates/create.json').
        with(
          :query => {:access_token => 'some_token'},
          :body => {
            "media"=>{"link"=>"http://google.com"},
            "profile_ids"=>[
              "4eb854340acb04e870000010",
              "4eb9276e0acb04bb81000067"],
            "text"=>"This is an example update"}).
        to_return(
          :body => fixture('success.json'),
          :status => 200)
    end

    it 'should make the correct POST to updates/create.json' do
      subject.post 'updates/create.json',
                   :text => "This is an example update",
                   :profile_ids => ['4eb854340acb04e870000010', '4eb9276e0acb04bb81000067'],
                   :media => {:link => "http://google.com"}
      a_post('updates/create.json').
        with(
          :query => {:access_token => 'some_token'},
          :body => fixture_contents('create_body.txt')).
        should have_been_made
    end

  end

end

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


