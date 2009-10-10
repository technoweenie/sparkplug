require 'rack-sparklines'
require 'fileutils'
require 'time'

class Rack::Sparklines
  module Cachers
    # Reads sparkline data from CSV files.  Only the first line of numbers are 
    # read.  Requests for "/sparks/stats.csv" will pass a data_path of "stats.csv"
    class Filesystem
      attr_accessor :png_path
      attr_accessor :directory

      def initialize(directory)
        @directory = directory
        @size, @updated_at = nil
      end

      # Setting the png_path returns a duplicate of this object that has any
      # custom instance variables (configuration settings, for example).
      def set(png_path)
        cacher = dup
        cacher.png_path = png_path
        cacher
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