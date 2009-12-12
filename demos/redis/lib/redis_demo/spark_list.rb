module RedisDemo
  # Persists sparkline data to Redis.  Data is pushed and popped from a Redis list.
  class SparkList
    attr_reader :redis
    attr_accessor :prefix, :limit

    # SparkList options
    #   :prefix => 'plug'
    #   :limit  => 50
    #   :redis  => {} # passed to Redis
    def initialize(options = {})
      @prefix = options[:prefix] || 'plug'
      @limit  = options[:limit]  || 50
      @redis  = Redis.new(options[:redis] || {})
    end

    def find(name)
      Plug.new(self, name)
    end
  end

  # represents a list of datapoints
  class Plug
    def initialize(list, name)
      @list  = list
      @redis = @list.redis
      @name  = name
      @name_key = @updated_key = nil
    end

    def add(value)
      @redis.rpush(name_key, value.to_i)
      excess = count - @list.limit
      if excess > 0
        excess.times { @redis.lpop(name_key) }
      end
      self.updated_at = Time.now.utc
    end

    def datapoints
      @redis.lrange(name_key, 0, @list.limit-1).map! { |p| p.to_i }
    end

    def updated_at
      value = @redis.get(updated_key)
      value.nil? ? Time.now.utc : Time.parse(value)
    end

    def updated_at=(v)
      @redis.set(updated_key, v.to_s)
    end

    def delete
      @redis.delete(name_key)
      @redis.delete(updated_key)
    end

    def exists?
      count > 0
    end

    def count
      @redis.llen(name_key)
    end

    def name_key
      @name_key ||= plug_name(@name)
    end

    def updated_key
      @updated_key ||= plug_name(@name, :updated)
    end

    # convert a simple plug name to a full plug name
    def plug_name(plug, *extras)
      s = "#{@list.prefix}:#{plug}"
      extras.each { |e| s << ':' << e.to_s }
      s
    end
  end
end