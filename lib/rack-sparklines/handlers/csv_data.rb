require 'rack-sparklines/handlers/abstract_data'
module Rack::Sparklines::Handlers
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
      yield IO.read(@data_path).split("\n").first.split(",")
    end
  end
end