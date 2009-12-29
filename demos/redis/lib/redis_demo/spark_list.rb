module RedisDemo
  # Persists sparkline data to Redis.  Data is pushed and popped from a Redis list.
  class SparkList
    attr_reader :redis, :plug_list
    attr_accessor :prefix, :limit

    # SparkList options
    #   :prefix => 'plug'
    #   :limit  => 50
    #   :redis  => {} # passed to Redis
    def initialize(options = {})
      @cache_path = options[:cache_path]
      @prefix     = options[:prefix] || 'plug'
      @limit      = options[:limit]  || 50
      @index_key  = "#{@prefix}:index"
      @redis      = Redis.new(options[:redis] || {})
      @plug_list  = PlugList.new(self)
    end

    def find(name)
      Plug.new(self, name)
    end

    def unlink(name)
      return if !@cache_path
      plug_cache = File.join(@cache_path, "#{name}.png")
      File.unlink(plug_cache) if File.exist?(plug_cache)
    end
  end

  class PlugList
    def initialize(list)
      @list     = list
      @redis    = @list.redis
      @list_key = "#{@prefix}:sparkplug:list"
    end

    def add(plug)
      @redis.sadd @list_key, plug.name
      @redis.sort @list_key, :order => "ALPHA"
    end

    def delete(plug)
      @redis.srem @list_key, plug.name
    end

    def all
      @redis.smembers(@list_key)
    end
  end

  # represents a list of datapoints
  class Plug
    attr_reader :name

    def initialize(list, name)
      @list  = list
      @redis = @list.redis
      @name  = name
      @name_key = @updated_key = nil
    end

    def add(value)
      points = count
      @redis.rpush(name_key, value.to_i)
      if points.zero?
        @list.plug_list.add(self)
      end
      excess = points + 1 - @list.limit
      if excess > 0
        excess.times { @redis.lpop(name_key) }
      end
      self.updated_at = Time.now.utc
      unlink
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
      unlink
      @list.plug_list.delete(self)
      @redis.delete(name_key)
      @redis.delete(updated_key)
    end

    def unlink
      @list.unlink(@name)
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