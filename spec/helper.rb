require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'json'
require 'dotide'
require 'rspec'
require 'webmock/rspec'

WebMock.disable_net_connect!(:allow => 'coveralls.io')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

require 'vcr'
VCR.configure do |c|
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<DOTIDE_CLIENT_ID>") do
    test_dotide_client_id
  end
  c.filter_sensitive_data("<DOTIDE_CLIENT_SECRET>") do
    test_dotide_client_secret
  end
  c.filter_sensitive_data("<DOTIDE_ACCESS_TOKEN>") do
    test_dotide_access_token
  end
  c.default_cassette_options = {
    :serialize_with             => :json,
    # TODO: Track down UTF-8 issue and remove
    :preserve_exact_body_bytes  => true,
    :decode_compressed_response => true,
    :record                     => ENV['TRAVIS'] ? :none : :once
  }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

def test_dotide_client_id
  ENV.fetch 'TEST_DOTIDE_CLIENT_ID', 'x' * 20
end

def test_dotide_client_secret
  ENV.fetch 'TEST_DOTIDE_CLIENT_SECRET', 'x' * 40
end

def test_dotide_access_token
  ENV.fetch 'TEST_DOTIDE_ACCESS_TOKEN', 'x' * 40
end

def stub_delete(path)
  stub_request(:delete, dotide_url(path))
end

def stub_get(path)
  stub_request(:get, dotide_url(path))
end

def stub_head(path)
  stub_request(:head, dotide_url(path))
end

def stub_patch(path)
  stub_request(:patch, dotide_url(path))
end

def stub_post(path)
  stub_request(:post, dotide_url(path))
end

def stub_put(path)
  stub_request(:put, dotide_url(path))
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_response(file)
  {
    :body => fixture(file),
    :headers => {
      :content_type => 'application/json; charset=utf-8'
    }
  }
end

def dotide_url(path)
  "http://api.dotide.com/v1#{path}"
end

def basic_dotide_url(path, options = {})
  client_id = options.fetch(:client_id, test_dotide_client_id)
  client_secret = options.fetch(:client_secret, test_dotide_client_secret)

  "http://#{client_id}:#{client_secret}@api.dotide.com/v1#{path}"
end

def basic_auth_connection(client_id = test_dotide_client_id, client_secret = test_dotide_client_secret)
  connection = Dotide.connection
  connection.client_id = test_dotide_client_id
  connection.client_secret = test_dotide_client_secret

  connection
end

def oauth_connection
  Dotide::Connection.new(access_token: test_dotide_access_token)
end
