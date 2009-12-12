class Sparkplug
  module Handlers
    # Abstract class for retrieving the data and determining whether the cache
    # needs to be refreshed.
    class AbstractData
      attr_accessor :data_path

      # Setting the data_path returns a duplicate of this object that has any
      # custom instance variables (configuration settings, for example).
      def set(data_path)
        data = dup
        data.data_path = data_path
        data
      end

      def already_cached?(cacher)
        if cache_time = cacher.exists? && cacher.updated_at
          cache_time > updated_at
        end
      end

      def exists?
        false
      end

      def updated_at
        raise NotImplementedError
      end

      # Yield an array of numbers for sparkline datapoints.
      def fetch
        raise NotImplementedError
      end
    end
  end
end