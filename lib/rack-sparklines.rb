require 'spark_pr'
module Rack
  class Sparklines
    def initialize(app, options = {})
      @app, @options = app, options
    end

    def call(env)
      if env['PATH_INFO'][@options[:prefix]] == @options[:prefix]
        data_path = env['PATH_INFO'][@options[:prefix].size+1..-1]
        data_path.sub! /\.png$/, ''
        png_path   = data_path + ".png"
        cache_file = ::File.join(@options[:directory], png_path)
        handler    = @options[:handler].new(data_path)
        handler.fetch do |data|
          ::File.open(cache_file, 'wb' ) do |png|
            png << Spark.plot(data, :has_min => true, :has_max => true, 'has_last' => 'true', 'height' => '40', :step => 10, :normalize => 'logarithmic')
          end
        end
        @app.call(env)
      else
        @app.call(env)
      end
    end
  end
end