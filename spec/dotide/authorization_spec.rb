require 'helper'
require 'json'

describe Dotide::Authorization do
  before(:each) do
    Dotide.reset!
    @connection = basic_auth_connection
    @connection.use test_dotide_database
  end

  it "list access tokens", :vcr do
    path = "/#{test_dotide_database}/access_tokens"
    get_request = stub_request(:get, basic_dotide_url(path)).
        to_return(json_response('access_tokens.json'))
    access_tokens = @connection.access_tokens.all
    expect(access_tokens).to be_kind_of Array
    expect(access_tokens.length).to eq 2
    expect(access_tokens.first).to be_kind_of Dotide::Models::AccessToken
    assert_requested get_request
  end

  it "fetch one access token", :vcr do
    path = "/#{test_dotide_database}/access_tokens/9404fde90f5534164c4da5fd2551807c63352b48dbcb9cfde4f7cfb63da417df"
    get_request = stub_request(:get, basic_dotide_url(path)).
        to_return(json_response('access_token.json'))
    access_token = @connection.access_tokens.find_one('9404fde90f5534164c4da5fd2551807c63352b48dbcb9cfde4f7cfb63da417df')
    expect(access_token.access_token).to eq '9404fde90f5534164c4da5fd2551807c63352b48dbcb9cfde4f7cfb63da417df'
    expect(access_token.scopes).to be_kind_of Array
    expect(access_token.scopes.first).to be_kind_of Dotide::Models::Scope
    assert_requested get_request
  end

  it "create one access token", :vcr do
    path = "/#{test_dotide_database}/access_tokens"
    body = {
      scopes: [{
        permissions: ['read', 'write', 'delete'],
        global: true
      }]
    }
    post_request = stub_request(:post, basic_dotide_url(path)).
        with(
             content_type: 'application/json',
             body: body.to_json
             ).
        to_return(json_response('access_token.json'))
    token = @connection.access_tokens.create(body)
    expect(token).to be_kind_of Dotide::Models::AccessToken
    expect(token.persist?).to be_true
    assert_requested post_request
  end

  it "build one access token", :vcr do
    path = "/#{test_dotide_database}/access_tokens"
    body = {
      scopes: [{
        permissions: ['read', 'write', 'delete'],
        global: true
      }]
    }
    post_request = stub_request(:post, basic_dotide_url(path)).
        with(
             content_type: 'application/json',
             body: body.to_json
             ).
        to_return(json_response('access_token.json'))
    token = @connection.access_tokens.build(body)
    expect(token).to be_kind_of Dotide::Models::AccessToken
    expect(token.persist?).to be_false
    token.save
    expect(token.persist?).to be_true
    assert_requested post_request
  end

  it "delete a access token from collection", :vcr do
    path = "/#{test_dotide_database}/access_tokens/9404fde90f5534164c4da5fd2551807c63352b48dbcb9cfde4f7cfb63da417df"
    delete_request = stub_request(:delete, basic_dotide_url(path))
    @connection.access_tokens.destroy_one('9404fde90f5534164c4da5fd2551807c63352b48dbcb9cfde4f7cfb63da417df')
    assert_requested delete_request
  end

  it "delete a access token in model", :vcr do
    path = "/#{test_dotide_database}/access_tokens"
    body = {
      scopes: [{
        permissions: ['read', 'write', 'delete'],
        global: true
      }]
    }
    post_request = stub_request(:post, basic_dotide_url(path)).
        with(content_type: 'application/json', body: body.to_json).
        to_return(json_response('access_token.json'))
    path = path + '/9404fde90f5534164c4da5fd2551807c63352b48dbcb9cfde4f7cfb63da417df'
    delete_request = stub_request(:delete, basic_dotide_url(path))
    token = @connection.access_tokens.create(body)
    token.destroy
    assert_requested delete_request
  end
end
