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
  c.filter_sensitive_data("<DOTIDE_LOGIN>") do
      ENV['TEST_DOTIDE_LOGIN']
  end
  c.filter_sensitive_data("<DOTIDE_PASSWORD>") do
      ENV['TEST_DOTIDE_PASSWORD']
  end
  c.filter_sensitive_data("<<AUTH_TOKEN>>") do
      ENV['TEST_DOTIDE_TOKEN']
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

def test_dotide_login
  ENV.fetch 'TEST_DOTIDE_LOGIN'
end

def test_dotide_password
  ENV.fetch 'TEST_DOTIDE_PASSWORD'
end

def test_dotide_token
  ENV.fetch 'TEST_DOTIDE_TOKEN'
end

def stub_delete(url)
  stub_request(:delete, dotide_url(url))
end

def stub_get(url)
  stub_request(:get, dotide_url(url))
end

def stub_head(url)
  stub_request(:head, dotide_url(url))
end

def stub_patch(url)
  stub_request(:patch, dotide_url(url))
end

def stub_post(url)
  stub_request(:post, dotide_url(url))
end

def stub_put(url)
  stub_request(:put, dotide_url(url))
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

def dotide_url(url)
  url =~ /^http/ ? url : "http://api.dotide.com/v1/#{url}"
end

def basic_dotide_url(path, options = {})
  login = options.fetch(:login, test_dotide_login)
  password = options.fetch(:password, test_dotide_password)

  "https://#{login}:#{password}@api.dotide.com#{path}"
end

def basic_auth_client(login = test_dotide_login, password = test_dotide_password )
  client = Dotide.client
  client.login = test_dotide_login
  client.password = test_dotide_password

  client
end

# def oauth_client
#   Dotide::Client.new(:access_token => ENV.fetch('TEST_DOTIDE_TOKEN'))
# end
