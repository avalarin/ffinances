class AccountController < ApplicationController
  before_filter :authorize, only: :success_registration

  class Login
    include ActiveModel::Model
    attr_accessor :name, :password, :remember
    validates :name, :password, presence: true
  end

  def login
    if (authenticated?)
        return redirect_to root_path
    end
    @login = Login.new
  end

  def do_login
    login = params.require(:login).permit(:name, :password, :remember)
    user = User.find_by_name(login[:name])
    if (user)
        if (user.locked)
            flash.now.alert = t('errors.messages.user_locked')
        elsif (!user.authenticate(login[:password]))
            flash.now.alert = t('errors.messages.invalid_email_or_password')
        else
          client_ip = request.env['REMOTE_ADDR']
          client_user_agent = request.env['HTTP_USER_AGENT']
          login_user user, login[:remember] == "true", ip: client_ip, user_agent: client_user_agent
          return redirect_to(params[:r] || root_path)
        end
    else
      flash.now.alert = t('errors.messages.invalid_email_or_password')
    end
    @login = Login.new login
    render 'login'
  end

  def do_logout
    logout_user
    redirect_to login_path
  end

  def register
    success, message, invite = check_registration_mode
    unless success
      @message = message
      return render 'register_error'
    end
    @invite = invite
    @user = User.new
    render 'register'
  end

  def do_register
    success, message, invite = check_registration_mode
    return render_api_resp :bad_request, message: message unless success
    return render_api_resp :bad_request, message: 'validation_error', data: {
        'captcha' => [ t('errors.messages.invalid_captcha') ]
      } unless captcha_valid?

    user = User.new(params.require(:user).permit([:display_name, :name, :email, :password]))
    user.password_confirmation = user.password
    user.confirmation_code = SecureRandom.hex(12)
    if (user.valid?)
      if invite
        invite.activated = true
        invite.user = user
        invite.save!
      end
      user.save!
      UserMailer.success_registration(user).deliver

      client_ip = request.env['REMOTE_ADDR']
      client_user_agent = request.env['HTTP_USER_AGENT']
      login_user user, false, ip: client_ip, user_agent: client_user_agent

      return render_api_resp :ok
    end
    render_model_errors_api_resp user
  end

  def success_registration

  end

  def confirm
    user = User.find_by_confirmation_code(params.require(:code))
    if user
      user.confirmed = true
      user.confirmation_code = nil
      user.save!
    end
    redirect_to root_path
  end

  private

  def check_registration_mode
    message = nil
    invite = nil
    if Settings.security.registration_mode == :disabled
      message = 'registration_disabled'
    elsif Settings.security.registration_mode == :invites
      if params.has_key? :invite
        invite = Invite.find_by_code params[:invite]
        if !invite
          message = 'invite_not_found'
        elsif invite.activated
          message = 'invite_outdated'
        end
      else
        message = 'invite_required'
      end
    end
    return [message == nil, message, invite]
  end


end