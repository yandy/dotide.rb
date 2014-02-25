module Dotide
  module Data
    def datastreams
      @_datastreams ||= Dotide::Collection.new(self, Dotide::Models::Datastream, '/datastreams')
    end

    def datapoints(id)
      Dotide::Collection.new(self, Dotide::Models::Datapoint, "/datastreams/#{id}/datapoints")
    end
  end
end
