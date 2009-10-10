require 'rack-sparklines/abstract_data'
module Rack
  class Sparklines
    class StubbedData < AbstractData
      class << self
        attr_accessor :data
      end
      self.data = {}

      def initialize(data_path)
        super
        @data = self.class.data[data_path]
      end

      def data_updated_at
        @data[:updated]
      end

      def fetch
        yield @data[:contents]
      end
    end
  end
end