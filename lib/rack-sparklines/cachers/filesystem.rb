require 'rack-sparklines/cachers/abstract'
require 'fileutils'

class Rack::Sparklines
  module Cachers
    # Reads sparkline data from CSV files.  Only the first line of numbers are 
    # read.  Requests for "/sparks/stats.csv" will pass a data_path of "stats.csv"
    class Filesystem < Abstract
      attr_accessor :png_path

      def initialize(directory)
        @directory = directory
        super()
      end

      def png_path=(s)
        @cache_file = File.join(@directory, s)
        @png_path   = s
      end

      def size
        @size ||= File.size(@cache_file)
      end

      def exists?
        File.file?(@cache_file)
      end

      def updated_at
        @updated_at ||= File.mtime(@cache_file)
      end

      def save(data, options)
        FileUtils.mkdir_p(File.dirname(@cache_file))
        File.open(@cache_file, 'wb') do |png|
          png << Spark.plot(data, options)
        end
      end

      def stream
        ::File.open(@cache_file, "rb") do |file|
          while part = file.read(8192)
            yield part
          end
        end
      end
    end
  end
end