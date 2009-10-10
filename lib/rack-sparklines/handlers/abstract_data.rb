require 'rack-sparklines'
class Rack::Sparklines
  module Handlers
    class AbstractData
      def initialize(data_path)
        @data_path = data_path
      end

      def already_cached?(cache_file)
        if cache_time = File.file?(cache_file) && File.mtime(cache_file)
          cache_time > data_updated_at
        end
      end

      def data_updated_at
        raise NotImplementedError
      end

      def fetch
        raise NotImplementedError
      end
    end
  end
end