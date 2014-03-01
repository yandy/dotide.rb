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
      get_request = stub_get("/#{test_dotide_database}/datastreams").
          with(:query => { :tags => 'a,b,c' },
               :headers => {
                :authorization => "Bearer #{test_dotide_access_token}"
                }).
          to_return(json_response('datastreams.json'))
      ds = @datastreams.find(tags: ['a', 'b', 'c'])
      expect(ds).to be_kind_of Array
      expect(ds.length).to eq 16
      expect(ds.first).to be_kind_of Dotide::Models::Datastream
      assert_requested get_request
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
      post_request = stub_post("/#{test_dotide_database}/datastreams").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"},
               :content_type => 'application/json',
               :body => body.to_json
               ).
          to_return(json_response('datastream.json'))
      ds = @datastreams.build(body)
      expect(ds).to be_kind_of Dotide::Models::Datastream
      expect(ds.persist?).to be_false
      ds.save
      expect(ds.persist?).to be_true
      assert_requested post_request
    end

    it "delete a datastream from collection", :vcr do
      delete_request = stub_delete("/#{test_dotide_database}/datastreams/loc-123456").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"})
      @datastreams.destroy_one('loc-123456')
      assert_requested delete_request
    end

    it "delete a datastream in model", :vcr do
      body = {id: 'loc-123456'}
      stub_post("/#{test_dotide_database}/datastreams").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"},
               :content_type => 'application/json',
               :body => body.to_json
               ).
          to_return(json_response('datastream.json'))
      delete_request = stub_delete("/#{test_dotide_database}/datastreams/loc-123456").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"})
      ds = @datastreams.create(body)
      ds.destroy
      assert_requested delete_request
    end
  end

  describe "datapoints:" do
    before(:each) do
      body = {id: 'loc-123456'}
      stub_post("/#{test_dotide_database}/datastreams").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"},
               :content_type => 'application/json',
               :body => body.to_json
               ).
          to_return(json_response('datastream.json'))
      datastreams = @connection.datastreams
      @datastream = datastreams.create(body)
    end

    it "list datapoints using query params", :vcr do
      get_request = stub_get("/#{test_dotide_database}/datastreams/loc-123456/datapoints").
          with(:headers => {:authorization => "Bearer #{test_dotide_access_token}"},
               :query => {:interval => 3600, :summary => 1}
               ).
          to_return(json_response('datapoints_resp.json'))
      dps = @datastream.datapoints.find(interval: 3600, summary: 1)
      expect(dps.id).to be_kind_of String
      expect(dps.options).to be_kind_of Hash
      expect(dps.summary).to be_kind_of Hash
      expect(dps.datapoints).to be_kind_of Array
      expect(dps.datapoints.length).to eq 2
      assert_requested get_request
    end

    it "create a datapoint", :vcr do
      post_request = stub_post("/#{test_dotide_database}/datastreams/loc-123456/datapoints").
          with(headers: {authorization: "Bearer #{test_dotide_access_token}"},
               content_type: 'application/json',
               body: {t: '2014-01-03T00:00:01Z', v: 10}.to_json
               ).
          to_return(headers: {content_type: 'application/json; charset=utf-8'},
                    body: {t: '2014-01-03T00:00:01Z', v: 10}.to_json,
                    status: 201
                    )
      dp = @datastream.datapoints.create(t: '2014-01-03T00:00:01Z', v: 10)
      expect(dp.t).to be_kind_of String
      expect(dp.v).to be_kind_of Integer
      assert_requested post_request
    end

    it "build a datapoint", :vcr do
      post_request = stub_post("/#{test_dotide_database}/datastreams/loc-123456/datapoints").
          with(headers: {authorization: "Bearer #{test_dotide_access_token}"},
               content_type: 'application/json',
               body: {t: '2014-01-03T00:00:01Z', v: 10}.to_json
               ).
          to_return(headers: {content_type: 'application/json; charset=utf-8'},
                    body: {t: '2014-01-03T00:00:01Z', v: 10}.to_json,
                    status: 201
                    )
      dp = @datastream.datapoints.build(t: '2014-01-03T00:00:01Z', v: 10)
      expect(dp).to be_kind_of Dotide::Models::Datapoint
      expect(dp.persist?).to be_false
      dp.save
      expect(dp.persist?).to be_true
      assert_requested post_request
    end

    it "create datapoints", :vcr do
      post_request = stub_post("/#{test_dotide_database}/datastreams/loc-123456/datapoints").
          with(headers: {authorization: "Bearer #{test_dotide_access_token}"},
               content_type: 'application/json',
               body: [{t: '2014-01-03T00:00:01Z', v: 10}, {t: '2014-01-03T00:20:01Z', v: 12}].to_json
               ).
          to_return(headers: {content_type: 'application/json; charset=utf-8'},
                    body: [{t: '2014-01-03T00:00:01Z', v: 10}, {t: '2014-01-03T00:20:01Z', v: 12}].to_json,
                    status: 201
                    )
      dps = @datastream.datapoints.create([{t: '2014-01-03T00:00:01Z', v: 10}, {t: '2014-01-03T00:20:01Z', v: 12}])
      expect(dps).to be_kind_of Array
      expect(dps.length).to eq 2
      assert_requested post_request
    end

    it "delete datapoints according query params", :vcr do
      delete_request = stub_delete("/#{test_dotide_database}/datastreams/loc-123456/datapoints").
          with(headers: {authorization: "Bearer #{test_dotide_access_token}"},
               query: {start: '2014-01-03T00:00:01Z', end: '2014-01-03T00:20:01Z'}
               )
      @datastream.datapoints.destroy_all(start: '2014-01-03T00:00:01Z', end: '2014-01-03T00:20:01Z')
      assert_requested delete_request
    end
  end
end
