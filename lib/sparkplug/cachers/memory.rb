require 'sparkplug/cachers/abstract'
require 'fileutils'

class Sparkplug
  module Cachers
    # Reads sparkline data from CSV files.  Only the first line of numbers are 
    # read.  Requests for "/sparks/stats.csv" will pass a data_path of "stats.csv"
    class Memory < Abstract
      attr_accessor :sparklines, :cache_time

      def initialize(cache_time = 86400)
        @cache_time = cache_time
        super()
      end

      def size
        @sparklines ? @sparklines.size : 0
      end

      def exists?
        @sparklines
      end

      def updated_at
        Time.now.utc
      end

      def save(data, options)
        @sparklines = create_sparklines(data, options)
      end

      def stream
        yield @sparklines
      end

      def serve(app, headers = {})
        headers['Cache-Control'] = "public, max-age=#{@cache_time}"
        super(app, headers)
      end
    end
  end
end