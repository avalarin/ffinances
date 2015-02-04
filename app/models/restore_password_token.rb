class RestorePasswordToken
  attr_accessor :user_name, :user_email, :expire_date, :code

  def self.create(user, expire_date)
    token = RestorePasswordToken.new
    token.user_name = user.name
    token.user_email = user.email
    token.expire_date = expire_date
    token.code = SecureRandom.hex(12)

    token
  end

  def self.from_json json
    data = JSON.parse json
    token = RestorePasswordToken.new
    token.user_name = data['user_name']
    token.user_email = data['user_email']
    token.expire_date = DateTime.parse(data['expire_date'])
    token.code = data['code']

    token
  end

  def save
    Redis.instance.set('restore_' + code, self.to_json)
  end

  def delete
    Redis.instance.del('restore_' + code)
  end

  def self.load code
    json = Redis.instance.get('restore_' + code)
    return nil unless json
    return RestorePasswordToken.from_json(json)
  end

  def expired?
    expire_date < DateTime.now
  end

end