module Sparkplug::Handlers
  # Reads sparkline data from CSV files.  Only the first line of numbers are 
  # read.  Requests for "/sparks/stats.csv" will pass a data_path of "stats.csv"
  class CsvData < AbstractData
    attr_accessor :directory

    def initialize(directory)
      @directory = directory
    end

    def data_path=(s)
      @data_path = s ? File.join(@directory, s) : nil
    end

    def exists?
      File.exist?(@data_path)
    end

    def updated_at
      File.mtime(@data_path)
    end

    def fetch
      array_of_nums = IO.read(@data_path).split("\n").first.split(",")
      array_of_nums.map! { |n| n.to_i }
      yield array_of_nums
    end
  end
end