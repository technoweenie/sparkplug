require 'spark_pr'
require 'time'

module Rack
  # Render sparkline graphs dynamically from datapoints in a matching CSV file 
  # (or anything that there is a Handler for).
  class Sparklines
    DEFAULT_SPARK_OPTIONS = {:has_min => true, :has_max => true, 'has_last' => 'true', 'height' => '40', :step => 10, :normalize => 'logarithmic'}

    # Options:
    #   :spark     - Hash of sparkline options.  See spark_pr.rb
    #   :prefix    - URL prefix for handled requests.  Setting it to "/sparks"
    #     treats requests like "/sparks/stats.csv" as dynamic sparklines.
    #   :directory - local directory that cached PNG files are stored.
    #   :handler   - Handler instances know how to fetch data and pass them 
    #     to the Sparklines library.
    def initialize(app, options = {})
      @app, @options   = app, options
      @options[:spark] = DEFAULT_SPARK_OPTIONS.merge(@options[:spark] || {})
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      if env['PATH_INFO'][@options[:prefix]] == @options[:prefix]
        @data_path = env['PATH_INFO'][@options[:prefix].size+1..-1]
        @data_path.sub! /\.png$/, ''
        @png_path   = @data_path + ".png"
        @cache_file = ::File.join(@options[:directory], @png_path)
        @handler    = @options[:handler].set(@data_path)
        if !@handler.exists?
          return @app.call(env)
        end
        if !@handler.already_cached?(@cache_file)
          @handler.fetch do |data|
            ::File.open(@cache_file, 'wb') do |png|
              png << Spark.plot(data, @options[:spark])
            end
          end
        end
       [200, {
          "Last-Modified"  => ::File.mtime(@cache_file).rfc822,
          "Content-Type"   => "image/png",
          "Content-Length" => ::File.size(@cache_file).to_s
        }, self]
      else
        @app.call(env)
      end
    end

    def each
      ::File.open(@cache_file, "rb") do |file|
        while part = file.read(8192)
          yield part
        end
      end
    end
  end
end