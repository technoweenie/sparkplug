module Sparkplug::Handlers
  # Allows you to stub sparkline data in a global hash.  Requests for 
  # "/sparks/stats.csv" will pass a data_path of "stats.csv"
  class StubbedData < AbstractData
    # A hash of hashes where the key is the filename.  The key points to
    # a hash with :updated and :contents keys
    #
    #   StubbedData.datasets['stats.csv'] = {
    #     :updated  => Time.utc(2009, 10, 1), 
    #     :contents => [1, 2, 3, 4, 5]}
    attr_accessor :datasets

    def initialize(datasets = {})
      @datasets = datasets
    end

    def data_path=(s)
      @data = @datasets[s]
      @data_path = s
    end

    def exists?
      @data
    end

    def updated_at
      @data[:updated]
    end

    def fetch
      yield @data[:contents] if @data
    end
  end
end