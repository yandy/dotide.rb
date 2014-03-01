require 'dotide/models/datapoint'
require 'dotide/collections/datapoints'
require 'dotide/models/datastream'
require 'dotide/collections/datastreams'

module Dotide
  module Data
    def datastreams
      @_datastreams ||= Dotide::Collections::Datastreams.new(self)
    end

    def datapoints(datastream_id)
      Dotide::Collection::Datapoints.new(self, datastream_id)
    end
  end
end
