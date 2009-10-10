require 'rack-sparklines/handlers/abstract_data'

module Rack::Sparklines::Handlers
  # Allows you to stub sparkline data in a global hash.  Requests for 
  # "/sparks/stats.csv" will pass a data_path of "stats.csv"
  class StubbedData < AbstractData
    class << self
      # Data is a hash of hashes.  The key is the filename, which points to
      # a hash with :updated and :contents keys
      #
      #   StubbedData.data['stats.csv'] = {
      #     :updated  => Time.utc(2009, 10, 1), 
      #     :contents => [1, 2, 3, 4, 5]}
      attr_accessor :data
    end
    self.data = {}

    def initialize(data_path)
      super
      @data = self.class.data[data_path]
    end

    def data_exists?
      @data
    end

    def data_updated_at
      @data[:updated]
    end

    def fetch
      yield @data[:contents] if @data
    end
  end
end