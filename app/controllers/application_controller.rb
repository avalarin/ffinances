class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionHelper
  include RenderHelper
  include SecurityHelper
  include UserProfileHelper

  helper BootstrapHelpers::Helpers

  prepend_before_action do
    flash[:messages] = params[:m] if params[:m]
    if (cookies[:messages])
      if (flash[:messages])
        flash[:messages] << ","
      else
        flash[:messages] = ""
      end
      flash[:messages] << cookies[:messages]
      cookies[:messages] = ""
    end
    m = (flash[:messages] || '').to_str.split(',')
    m.each do |name|
      initializer = self.class.find_initializer(name)
      next unless initializer
      if initializer.is_a? Proc
        message = instance_eval(&initializer)
        messages.push(message) 
      else
        messages.push(Message.new(initializer))
      end
    end
  end
  
  def authorize role = nil
    if (!authenticated?)
      respond_to do |f|
        f.json do
          render_api_resp :unauthorized, data: {
            login_page: login_path
          }
        end
        f.html do
          redirect_to login_path(r: request.fullpath)
        end
      end
      return false
    end
    if (role && !current_user.has_role?(role))
      respond_to do |f|
        f.json do
          render_api_resp :unauthorized, message: 'access_denied'
        end
        f.html do
          raise 'access_denied'
        end
      end
      return false
    end
    true
  end
  
  def need_book role = nil
    book = current_book
    if (!book)
      redirect_to books_index_path
      return false
    end
    if (role)
      unless has_book_role role
        respond_to do |f|
          f.json do
            render_api_resp :unauthorized, message: 'access_denied'
          end
          f.html do
            raise 'access_denied'
          end
      end
        return false
      end
    end
    true
  end

  def has_book_role role
    role_index = get_book_role_index role
    user_role_index = get_book_role_index current_book_role
    return role_index <= user_role_index
  end

  class << self
    def enabled_messages
      @enabled_messages = { } unless @enabled_messages
      @enabled_messages
    end

    def find_initializer(name)
      initializer = enabled_messages[name]
      return initializer if initializer
      if (superclass.respond_to? :find_initializer)
        return superclass.find_initializer(name)
      end
    end

    private

    def enable_messages s
      s.each do |k, v|
        enabled_messages[k] = v
      end
    end
  end

  def messages
    @messages = [] unless @messages
    @messages
  end

  enable_messages({})
end
