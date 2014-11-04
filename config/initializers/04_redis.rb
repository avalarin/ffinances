require "redis"

class Redis
  uri = URI.parse(Settings.redis)
  @@instance = Redis.new(path: uri.path ,host: uri.host, port: uri.port, password: uri.password, thread_safe: true)
  def self.instance
    @@instance
  end
end