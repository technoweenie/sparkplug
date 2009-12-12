module RedisDemo
  # Persists sparkline data to Redis.  Data is pushed and popped from a Redis list.
  class SparkList
    attr_reader :redis

    def initialize(connection_options = {})
      @redis = Redis.new(connection_options)
    end

    # convert a simple plug name to a full plug name
    def plug_name(plug, *extras)
      s = "plug:#{plug}:"
      extras.each { |e| s << e.to_s << ':' }
      s
    end

    # pass a simple plug name
    def delete(name)
      @redis.delete plug_name(name)
      @redis.delete plug_name(name, :updated)
    end

    # pass a simple plug name
    def datapoints_for(name)
      plug = plug_name(name)
      @redis.lrange(plug, 0, 49).map! { |p| p.to_i }
    end

    # pass a simple plug name
    def add_datapoint(name, value)
      plug = plug_name(name)
      @redis.rpush(plug, value.to_i)
      excess = count_for(plug) - 50
      if excess > 0
        excess.times { @redis.lpop(plug) }
      end
      @redis.set(plug_name(name, :updated), Time.now.utc.to_s)
    end

    # pass a simple plug name
    def updated_at_for(plug)
      value = @redis.get plug_name(plug, :updated)
      value.nil? ? Time.now.utc : Time.parse(value)
    end

    # pass a simple plug name
    def exists?(name)
      plug = plug_name(name)
      !count_for(plug).zero?
    end

    # pass a full plug name
    def count_for(plug)
      @redis.llen(plug)
    end
  end
end