require 'rack-sparklines'

class Rack::Sparklines
  module Handlers
    # Abstract class for retrieving the data and determining whether the cache
    # needs to be refreshed.
    class AbstractData
      def initialize(data_path)
        @data_path = data_path
      end

      def already_cached?(cache_file)
        if cache_time = File.file?(cache_file) && File.mtime(cache_file)
          cache_time > data_updated_at
        end
      end

      def data_exists?
        false
      end

      def data_updated_at
        raise NotImplementedError
      end

      # Yield an array of numbers for sparkline datapoints.
      def fetch
        raise NotImplementedError
      end
    end
  end
end