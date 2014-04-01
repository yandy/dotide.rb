require 'dotide/models/datapoint'
require 'dotide/collections/datapoints'
require 'dotide/models/datastream'
require 'dotide/collections/datastreams'

module Dotide

  # Data manipulates methods for {Dotide::Connection}
  module Data

    # Return the {Dotide::Collections::Datastreams} of current {Dotide::Connection}
    # @return [Dotide::Collections::Datastreams]
    def datastreams
      @_datastreams ||= Dotide::Collections::Datastreams.new(self)
    end

    # Return the {Dotide::Collections::Datapoints} of current {Dotide::Connection}
    # @return [Dotide::Collections::Datapoints]
    def datapoints(datastream_id)
      Dotide::Collection::Datapoints.new(self, datastream_id)
    end
  end
end
