require 'spark_pr'
module Rack
  class Sparklines
    def initialize(app, options = {})
      @app, @options = app, options
    end

    def call(env)
      @app.call(env)
    end
  end
end