require 'helper'
require 'json'

describe Dotide::Client do

  before do
    Dotide.reset!
  end

  after do
    Dotide.reset!
  end

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
          :client_id    => test_dotide_client_id,
          :client_secret => test_dotide_client_secret
        }
      end

      it "overrides module configuration" do
        client = Dotide::Client.new(@opts)
        expect(client.client_id).to eq test_dotide_client_id
        expect(client.instance_variable_get(:"@client_secret")).to eq test_dotide_client_secret
      end

      it "can set configuration after initialization" do
        client = Dotide::Client.new
        client.configure do |config|
          @opts.each do |key, value|
            config.send("#{key}=", value)
          end
        end
        expect(client.client_id).to eq test_dotide_client_id
        expect(client.instance_variable_get(:"@client_secret")).to eq test_dotide_client_secret
      end

      it "masks client_secret on inspect" do
        client = Dotide::Client.new(@opts)
        inspected = client.inspect
        expect(inspected).to_not include test_dotide_client_secret
      end

      it "masks tokens on inspect" do
        client = Dotide::Client.new(:access_token => test_dotide_access_token)
        inspected = client.inspect
        expect(inspected).to_not match test_dotide_access_token
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
          config.client_id = test_dotide_client_id
          config.client_secret = test_dotide_client_secret
        end
        expect(Dotide.client).to be_basic_authenticated
      end
      it "sets basic auth creds with module methods" do
        Dotide.client_id = test_dotide_client_id
        Dotide.client_secret = test_dotide_client_secret
        expect(Dotide.client).to be_basic_authenticated
      end
      it "sets oauth token with .configure" do
        Dotide.configure do |config|
          config.access_token = test_dotide_access_token
        end
        expect(Dotide.client).to_not be_basic_authenticated
        expect(Dotide.client).to be_token_authenticated
      end
      it "sets oauth token with module methods" do
        Dotide.access_token = test_dotide_access_token
        expect(Dotide.client).to_not be_basic_authenticated
        expect(Dotide.client).to be_token_authenticated
      end
    end

    describe "with class level config" do
      it "sets basic auth creds with .configure" do
        @client.configure do |config|
          config.client_id = test_dotide_client_id
          config.client_secret = test_dotide_client_secret
        end
        expect(@client).to be_basic_authenticated
      end
      it "sets basic auth creds with instance methods" do
        @client.client_id = test_dotide_client_id
        @client.client_secret = test_dotide_client_secret
        expect(@client).to be_basic_authenticated
      end
      it "sets oauth token with .configure" do
        @client.configure do |config|
          config.access_token = test_dotide_access_token
        end
        expect(@client).to_not be_basic_authenticated
        expect(@client).to be_token_authenticated
      end
      it "sets oauth token with instance methods" do
        @client.access_token = test_dotide_access_token
        expect(@client).to_not be_basic_authenticated
        expect(@client).to be_token_authenticated
      end
    end

    describe "when basic authenticated"  do
      it "makes authenticated calls" do
        Dotide.configure do |config|
          config.client_id = test_dotide_client_id
          config.client_secret = test_dotide_client_secret
        end

        VCR.turned_off do
          root_request = stub_request(:get, "http://#{test_dotide_client_id}:#{test_dotide_client_secret}@api.dotide.com/v1/")
          Dotide.client.get("/")
          assert_requested root_request
        end
      end
    end

    describe "when token authenticated", :vcr do
      it "makes authenticated calls" do
        client = oauth_client

        root_request = stub_get("/").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"})
        client.get("/")
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
      VCR.use_cassette 'root' do
        root = Dotide.client.root
        expect(root.version).to eq "1"
      end
    end
  end

  describe ".last_response", :vcr do
    it "caches the last agent response" do
      Dotide.reset!
      client = Dotide.client
      expect(client.last_response).to be_nil
      client.get "/"
      expect(client.last_response.status).to eq 200
    end
  end # .last_response

  describe ".get", :vcr do
    before(:each) do
      Dotide.reset!
    end
    it "handles query params" do
      Dotide.get "/", :foo => "bar"
      assert_requested :get, 'http://api.dotide.com/v1/?foo=bar'
    end
    it "handles headers" do
      request = stub_get("/zen").
        with(:query => {:foo => "bar"},
             :headers => {
              :accept => "application/json"
              })
      Dotide.get "/zen", :foo => "bar", :accept => "application/json"
      assert_requested request
    end
  end # .get

  describe ".head", :vcr do
    before(:each) do
      Dotide.reset!
    end
    it "handles query params" do
      Dotide.head "/", :foo => "bar"
      assert_requested :head, 'http://api.dotide.com/v1/?foo=bar'
    end
    it "handles headers" do
      request = stub_head("/zen").
        with(:query => {:foo => "bar"},
             :headers => {
              :accept => "application/json"
              })
      Dotide.head "/zen", :foo => "bar", :accept => "application/json"
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
      user_agent = "Mozilla/5.0 I am Qin!"
      root_request = stub_get("/").
        with(:headers => {:user_agent => user_agent})
      @client.user_agent = user_agent
      @client.get "/"
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
        :body => {:message => "No datastream found for iphone"}.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.message).to include \
          "GET http://api.dotide.com/v1/boom: 422 - No datastream found"
      end
    end

    it "includes an error" do
      stub_get('/boom').
        to_return \
        :status => 422,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:error => "No datastream found for iphone"}.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.message).to include \
          "GET http://api.dotide.com/v1/boom: 422 - Error: No datastream found"
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
          :message => "database not found",
          :errors => [
            :resource => "Database",
            :field    => "name"
          ]
        }.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.message).to include \
          "GET http://api.dotide.com/v1/boom: 422 - database not found"
        expect(e.message).to include "  resource: Database"
        expect(e.message).to include "  field: name"
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
          :message => "database not found",
          :errors => [
            :resource => "Database",
            :field    => "name"
          ]
        }.to_json
      begin
        Dotide.get('/boom')
      rescue Dotide::UnprocessableEntity => e
        expect(e.errors.first[:resource]).to eq("Database")
        expect(e.errors.first[:field]).to eq("name")
      end
    end

    it "raises on unknown connection errors" do
      stub_get('/user').to_return \
        :status => 418,
        :headers => {
          :content_type => "application/json",
        },
        :body => {:message => "I'm loving Dotide"}.to_json
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
      stub_get('/user').to_return \
        :status => 415,
        :headers => {
          :content_type => "application/json",
        },
        :body => {
          :message => "Unsupported Media Type",
          :documentation_url => "http://developer.dotide.com/docs"
        }.to_json
      begin
        Dotide.get('/user')
      rescue Dotide::UnsupportedMediaType => e
        msg = "415 - Unsupported Media Type"
        expect(e.message).to include(msg)
        expect(e.documentation_url).to eq("http://developer.dotide.com/docs")
      end
    end
  end

end
