require 'spark_pr'

module Rack
  # Render sparkline graphs dynamically from datapoints in a matching CSV file 
  # (or anything that there is a Handler for).
  class Sparklines
    DEFAULT_SPARK_OPTIONS = {:has_min => true, :has_max => true, :height => 40, :step => 10}

    # Options:
    #   :spark   - Hash of sparkline options.  See spark_pr.rb
    #   :prefix  - URL prefix for handled requests.  Setting it to "/sparks"
    #     treats requests like "/sparks/stats.csv" as dynamic sparklines.
    #   :cacher  - Cachers know how to store and stream sparkline PNG data.
    #   :handler - Handler instances know how to fetch data and pass them 
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
        @png_path = @data_path + ".png"
        @cacher   = @options[:cacher].set(@png_path)
        @handler  = @options[:handler].set(@data_path)
        if !@handler.exists?
          return @app.call(env)
        end
        if !@handler.already_cached?(@cacher)
          @handler.fetch do |data|
            @cacher.save(data, @options[:spark])
          end
        end
        @cacher.serve(self)
      else
        @app.call(env)
      end
    end

    def each
      @cacher.stream { |part| yield part }
    end
  end
end