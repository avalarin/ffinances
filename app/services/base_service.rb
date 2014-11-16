class BaseService
  attr_accessor :current_user, :params

  def initialize(current_user, params)
    @current_user, @params = current_user, params.dup
  end

  def log_action(user, action, object, context = null)

  end

end