require 'rack-sparklines/handlers/abstract_data'
module Rack::Sparklines::Handlers
  class StubbedData < AbstractData
    class << self
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