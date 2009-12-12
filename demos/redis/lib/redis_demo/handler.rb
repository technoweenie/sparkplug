module RedisDemo
  class Handler < Sparkplug::Handlers::AbstractData
    attr_reader :list

    def initialize(connection_options = {})
      @list = SparkList.new(connection_options)
    end

    def data_path=(v)
      v.sub!(/^\//, '')
      @data_path = v
    end

    def exists?
      @list.exists?(@data_path)
    end

    def updated_at
      @list.updated_at_for(@data_path)
    end

    def fetch
      yield @list.datapoints_for(@data_path)
    end
  end
end