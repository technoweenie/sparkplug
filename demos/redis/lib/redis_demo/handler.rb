module RedisDemo
  class Handler < Sparkplug::Handlers::AbstractData
    attr_reader :list

    def initialize(list)
      @list = list
    end

    def data_path=(v)
      v.sub!(/^\//, '')
      @data_path = v
      @plug      = @list.find(@data_path)
    end

    def exists?
      @plug.exists?
    end

    def updated_at
      @plug.updated_at
    end

    def fetch
      yield @plug.datapoints
    end
  end
end