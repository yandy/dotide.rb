require 'helper'
require 'json'

describe "Manipulate" do
  before(:each) do
    Dotide.reset!
    @connection = oauth_connection
    @connection.use test_dotide_database
  end

  describe "datastreams:" do
    before(:each) do
      @datastreams = @connection.datastreams
    end

    it 'list datastreams using query params', :vcr do
      query_request = stub_get("/#{test_dotide_database}/datastreams").
          with(:query => { :tags => 'a,b,c' },
               :headers => {
                :authorization => "Bearer #{test_dotide_access_token}"
                }).
          to_return(json_response('datastreams.json'))
      ds = @datastreams.find(tags: 'a,b,c')
      expect(ds).to be_kind_of Array
      expect(ds.length).to eq 16
      expect(ds.first).to be_kind_of Dotide::Models::Datastream
      assert_requested query_request
    end

    it 'fetch one datastream', :vcr do
      get_request = stub_get("/#{test_dotide_database}/datastreams/loc-123456").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"}).
          to_return(json_response('datastream.json'))
      ds = @datastreams.find_one('loc-123456')
      expect(ds).to be_kind_of Dotide::Models::Datastream
      assert_requested get_request
    end

    it "create a datastream", :vcr do
      body = {id: 'loc-123456'}
      post_request = stub_post("/#{test_dotide_database}/datastreams").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"},
               :content_type => 'application/json',
               :body => body.to_json
               ).
          to_return(json_response('datastream.json'))
      ds = @datastreams.create(body)
      expect(ds).to be_kind_of Dotide::Models::Datastream
      expect(ds.persist?).to be_true
      assert_requested post_request
    end

    it "build a datastream model" do
      body = {id: 'loc-123456'}
      ds = @datastreams.build(body)
      expect(ds).to be_kind_of Dotide::Models::Datastream
      expect(ds.persist?).to be_false
    end
  end

  describe "datapoints:" do
  end
end
