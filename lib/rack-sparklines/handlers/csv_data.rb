require 'rack-sparklines/handlers/abstract_data'

module Rack::Sparklines::Handlers
  # Reads sparkline data from CSV files.  Only the first line of numbers are 
  # read.  Requests for "/sparks/stats.csv" will pass a data_path of "stats.csv"
  class CsvData < AbstractData
    class << self
      attr_accessor :directory
    end

    def initialize(data_path)
      @data_path = File.join(self.class.directory, data_path)
    end

    def data_exists?
      File.exist?(@data_path)
    end

    def data_updated_at
      File.mtime @data_path
    end

    def fetch
      array_of_nums = IO.read(@data_path).split("\n").first.split(",")
      array_of_nums.map! { |n| n.to_i }
      yield array_of_nums
    end
  end
end