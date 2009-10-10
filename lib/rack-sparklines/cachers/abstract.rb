require 'rack-sparklines'
require 'time'

class Rack::Sparklines
  module Cachers
    # Reads sparkline data from CSV files.  Only the first line of numbers are 
    # read.  Requests for "/sparks/stats.csv" will pass a data_path of "stats.csv"
    class Abstract
      attr_accessor :png_path

      def initialize
        @size, @updated_at = nil
      end

      # Setting the png_path returns a duplicate of this object that has any
      # custom instance variables (configuration settings, for example).
      def set(png_path)
        cacher = dup
        cacher.png_path = png_path
        cacher
      end

      def size
        raise NotImplementedError
      end

      def exists?
        raise NotImplementedError
      end

      def updated_at
        raise NotImplementedError
      end

      def create_sparklines(data, options)
        Spark.plot(data, options)
      end

      def serve(app, headers = {})
        headers = {
          "Last-Modified"  => updated_at.rfc822,
          "Content-Type"   => "image/png",
          "Content-Length" => size.to_s
        }.update(headers)
        [200, headers, app]
      end

      def save(data, options)
        raise NotImplementedError
      end

      def stream
        raise NotImplementedError
      end
    end
  end
end