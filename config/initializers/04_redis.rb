require "redis"

class Redis
  @@instance = Redis.new(url: Settings.redis, thread_safe: true)

  def self.instance
    @@instance
  end
end