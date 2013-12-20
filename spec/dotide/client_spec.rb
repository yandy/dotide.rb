require 'helper'
require 'json'

describe Dotide::Client do

  describe "module configuration" do

    before do
      Dotide.reset!
      Dotide.configure do |config|
        Dotide::Configurable.keys.each do |key|
          config.send("#{key}=", "Some #{key}")
        end
      end
    end

    after do
      Dotide.reset!
    end

    it "inherits the module configuration" do
      client = Dotide::Client.new
      Dotide::Configurable.keys.each do |key|
        expect(client.instance_variable_get(:"@#{key}")).to eq "Some #{key}"
      end
    end

    describe "with class level configuration" do

      before do
        @opts = {
          :connection_options => {:ssl => {:verify => false}},
          :per_page => 40,
          :login    => "yandy",
          :password => "il0veruby"
        }
      end

      it "overrides module configuration" do
        client = Dotide::Client.new(@opts)
        expect(client.per_page).to eq 40
        expect(client.login).to eq "yandy"
        expect(client.instance_variable_get(:"@password")).to eq "il0veruby"
        expect(client.auto_paginate).to eq Dotide.auto_paginate
      end

      it "can set configuration after initialization" do
        client = Dotide::Client.new
        client.configure do |config|
          @opts.each do |key, value|
            config.send("#{key}=", value)
          end
        end
        expect(client.per_page).to eq 40
        expect(client.login).to eq "yandy"
        expect(client.instance_variable_get(:"@password")).to eq "il0veruby"
        expect(client.auto_paginate).to eq Dotide.auto_paginate
      end

      it "masks passwords on inspect" do
        client = Dotide::Client.new(@opts)
        inspected = client.inspect
        expect(inspected).to_not include "il0veruby"
      end

      it "masks tokens on inspect" do
        client = Dotide::Client.new(:auth_token => '87614b09dd141c22800f96f11737ade5226d7ba8', :login => 'yandy')
        inspected = client.inspect
        expect(inspected).to_not match "87614b09dd141c22800f96f11737ade5226d7ba8"
      end

      describe "with .netrc" do
        it "can read .netrc files" do
          Dotide.reset!
          client = Dotide::Client.new \
            :netrc => true,
            :netrc_file => File.join(fixture_path, '.netrc')
          expect(client.login).to eq "yandy"
          expect(client.instance_variable_get(:"@password")).to eq "il0veruby"
        end

        it "can read non-standard API endpoint creds from .netrc" do
          Dotide.reset!
          client = Dotide::Client.new \
            :netrc => true,
            :netrc_file => File.join(fixture_path, '.netrc'),
            :api_endpoint => 'http://api.dotide.dev'
          expect(client.login).to eq "yandy"
          expect(client.instance_variable_get(:"@password")).to eq "il0veruby"
        end
      end
    end
  end

  describe "authentication" do
    before do
      Dotide.reset!
      @client = Dotide.client
    end

    describe "with module level config" do
      before do
        Dotide.reset!
      end
      it "sets basic auth creds with .configure" do
        Dotide.configure do |config|
          config.login = 'lnn'
          config.password = 'il0veruby'
        end
        expect(Dotide.client).to be_basic_authenticated
      end
      it "sets basic auth creds with module methods" do
        Dotide.login = 'lnn'
        Dotide.password = 'il0veruby'
        expect(Dotide.client).to be_basic_authenticated
      end
      it "sets token auth with .configure" do
        Dotide.configure do |config|
          config.login = 'lnn'
          config.auth_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        end
        expect(Dotide.client).to_not be_basic_authenticated
        expect(Dotide.client).to be_token_authenticated
      end
      it "sets token auth with module methods" do
        Dotide.login = 'lnn'
        Dotide.auth_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        expect(Dotide.client).to_not be_basic_authenticated
        expect(Dotide.client).to be_token_authenticated
      end
    end

    describe "with class level config" do
      it "sets basic auth creds with .configure" do
        @client.configure do |config|
          config.login = 'lnn'
          config.password = 'il0veruby'
        end
        expect(@client).to be_basic_authenticated
      end
      it "sets basic auth creds with instance methods" do
        @client.login = 'lnn'
        @client.password = 'il0veruby'
        expect(@client).to be_basic_authenticated
      end
      it "sets token auth with .configure" do
        @client.configure do |config|
          config.login = 'lnn'
          config.auth_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        end
        expect(@client).to_not be_basic_authenticated
        expect(@client).to be_token_authenticated
      end
      it "sets token auth with instance methods" do
        @client.login = 'lnn'
        @client.auth_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        expect(@client).to_not be_basic_authenticated
        expect(@client).to be_token_authenticated
      end
    end

    describe "when basic authenticated"  do
      it "makes authenticated calls" do
        Dotide.configure do |config|
          config.login = 'lnn'
          config.password = 'il0veruby'
        end

        VCR.turn_off!
        root_request = stub_request(:get, "http://lnn:il0veruby@api.dotide.com/v1")
        Dotide.client.get("/v1")
        assert_requested root_request
        VCR.turn_on!
      end
    end
    describe "when token authenticated", :vcr do
      it "makes authenticated calls" do
        client = token_auth_client

        root_request = stub_get("/v1").
          with(:headers => {:authorization => "token #{test_dotide_login}:#{test_dotide_auth_token}"})
        client.get("/v1")
        assert_requested root_request
      end
    end
  end

  describe ".agent" do
    before do
      Dotide.reset!
    end
    it "acts like a Sawyer agent" do
      expect(Dotide.client.agent).to respond_to :start
    end
    it "caches the agent" do
      agent = Dotide.client.agent
      expect(agent.object_id).to eq Dotide.client.agent.object_id
    end
  end # .agent

  describe ".root" do
    it "fetches the API root" do
      Dotide.reset!
      Dotide.login = test_dotide_login
      Dotide.auth_token = test_dotide_auth_token
      VCR.use_cassette 'root' do
        root = Dotide.client.root
        expect(root.href).to eq "http://api.dotide.com/v1"
      end
    end
  end

  describe ".last_response", :vcr do
    it "caches the last agent response" do
      Dotide.reset!
      client = token_auth_client
      expect(client.last_response).to be_nil
      client.get "/v1"
      expect(client.last_response.status).to eq 200
    end
  end # .last_response

  describe ".get", :vcr do
    before(:each) do
      Dotide.reset!
      Dotide.login = test_dotide_login
      Dotide.auth_token = test_dotide_auth_token
    end
    it "handles query params" do
      request = stub_get('/v1').
        with(:query => {:foo => "bar"},
             :headers => {
              :authorization => "token #{test_dotide_login}:#{test_dotide_auth_token}"
              })
      Dotide.get "/v1", :foo => "bar"
      assert_requested request
    end
    it "handles headers" do
      request = stub_get("/v1").
        with(:query => {:foo => "bar"},
             :headers => {
              :accept => "application/json",
              :authorization => "token #{test_dotide_login}:#{test_dotide_auth_token}"
              })
      Dotide.get "/v1", :foo => "bar", :accept => "application/json"
      assert_requested request
    end
  end # .get

  describe ".head", :vcr do
    before(:each) do
      Dotide.reset!
      Dotide.login = test_dotide_login
      Dotide.auth_token = test_dotide_auth_token
    end
    it "handles query params" do
      request = stub_head('/v1').
        with(:query => {:foo => 'bar'},
             :headers => {
              :authorization => "token #{test_dotide_login}:#{test_dotide_auth_token}"
              }
             )
      Dotide.head "/v1", :foo => "bar"
      assert_requested request
    end
    it "handles headers" do
      request = stub_head("/v1").
        with(:query => {:foo => "bar"},
             :headers => {
              :accept => "application/json",
              :authorization => "token #{test_dotide_login}:#{test_dotide_auth_token}"
              })
      Dotide.head "/v1", :foo => "bar", :accept => "application/json"
      assert_requested request
    end
  end # .head

  describe "when making requests" do
    before do
      Dotide.reset!
      @client = Dotide.client
    end
    it "sets a default user agent" do
      root_request = stub_get("/").
        with(:headers => {:user_agent => Dotide::Default.user_agent})
      @client.get "/"
      assert_requested root_request
      expect(@client.last_response.status).to eq 200
    end
    it "sets a custom user agent" do
      user_agent = "Mozilla/5.0 I am Spartacus!"
      root_request = stub_get("/v1").
        with(:headers => {:user_agent => user_agent})
      @client.user_agent = user_agent
      @client.get "/v1"
      assert_requested root_request
      expect(@client.last_response.status).to eq 200
    end
    it "sets a proxy server" do
      @client.configure do |config|
        config.proxy = 'http://proxy.example.com:80'
      end
      conn = @client.send(:agent).instance_variable_get(:"@conn")
      expect(conn.proxy[:uri].to_s).to eq 'http://proxy.example.com'
    end
    it "passes along request headers for POST" do
      VCR.turn_off!
      headers = {"X-Dotide-Foo" => "bar"}
      root_request = stub_post("/").
        with(:headers => headers).
        to_return(:status => 201)
      @client.post "/", :headers => headers
      assert_requested root_request
      expect(@client.last_response.status).to eq 201
      VCR.turn_on!
    end
  end

  describe "auto pagination", :vcr do
    before do
      Dotide.reset!
      Dotide.configure do |config|
        config.auto_paginate = true
        config.per_page = 3
        config.login = test_dotide_login
        config.auth_token = test_dotide_auth_token
      end
    end

    after do
      Dotide.reset!
    end

    it "fetches all the pages" do
      Dotide.client.paginate('/v1/keys')
      assert_requested :get, dotide_url("/v1/keys?per_page=3")
      (2..7).each do |i|
        assert_requested :get, dotide_url("/v1/keys?per_page=3&page=#{i}")
      end
    end
  end

  context "error handling" do
    before do
      Dotide.reset!
      VCR.turn_off!
    end

    after do
      VCR.turn_on!
    end

    it "raises on 404" do
      stub_get('/booya').to_return(:status => 404)
      expect { Dotide.get('/booya') }.to raise_error Dotide::NotFound
    end

    it "raises on 500" do
      stub_get('/boom').to_return(:status => 500)
      expect { Dotide.get('/boom') }.to raise_error Dotide::InternalServerError
    end

    it "includes a message" do
      stub_get('/boom').
        to_return \
        :status => 422,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:message => "No repository found for iphone"}.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.message).to include \
          "GET http://api.dotide.com/boom: 422 - No repository found"
      end
    end

    it "includes an error" do
      stub_get('/boom').
        to_return \
        :status => 422,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:error => "No key found for iphone"}.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.message).to include \
          "GET http://api.dotide.com/boom: 422 - Error: No key found"
      end
    end

    it "includes an error summary" do
      stub_get('/boom').
        to_return \
        :status => 422,
        :headers => {
          :content_type => "application/json",
        },
        :body => {
          :message => "permissions is missing",
          :errors => [
            :resource => "Key",
            :field    => "label"
          ]
        }.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.message).to include \
          "GET http://api.dotide.com/boom: 422 - permissions is missing"
        expect(e.message).to include "  resource: Key"
        expect(e.message).to include "  field: label"
      end
    end

    it "exposes errors array" do
      stub_get('/boom').
        to_return \
        :status => 422,
        :headers => {
          :content_type => "application/json",
        },
        :body => {
          :message => "Validation Failed",
          :errors => [
            :resource => "Key",
            :field    => "label"
          ]
        }.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.errors.first[:resource]).to eq("Key")
        expect(e.errors.first[:field]).to eq("label")
      end
    end

    it "raises on unknown client errors" do
      stub_get('/user').to_return \
        :status => 418,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:message => "I'm loving Lnn"}.to_json
      expect { Dotide.get('/user') }.to raise_error Dotide::ClientError
    end

    it "raises on unknown server errors" do
      stub_get('/user').to_return \
        :status => 509,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:message => "Bandwidth exceeded"}.to_json
      expect { Dotide.get('/user') }.to raise_error Dotide::ServerError
    end

    it "handles documentation URLs in error messages" do
      stub_get('/v1/user').to_return \
        :status => 415,
        :headers => {
          :content_type => "application/json",
        },
        :body => {
          :message => "Unsupported Media Type",
          :documentation_url => "http://developer.dotide.com/v1"
        }.to_json
      begin
        Dotide.get('/v1/user')
      rescue Dotide::UnsupportedMediaType => e
        msg = "415 - Unsupported Media Type"
        expect(e.message).to include(msg)
        expect(e.documentation_url).to eq("http://developer.dotide.com/v1")
      end
    end
  end

end
