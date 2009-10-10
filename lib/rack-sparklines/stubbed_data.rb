require 'rack-sparklines'
module Rack
  class Sparklines
    class StubbedData
      class << self
        attr_accessor :data
      end
      self.data = {}

      def initialize(data_path)
        @data = self.class.data[data_path]
      end

      def fetch
        yield @data
      end
    end
  end
end