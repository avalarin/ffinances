class RestoreController < ApplicationController

  def start
    render 'start'
  end

  def send_email
    unless captcha_valid?
      flash.now.alert = t('errors.messages.invalid_captcha')
      return render 'start'
    end
    user_name = params.require(:user)[:name]
    return render_with_alert(t('errors.messages.user_not_found'), 'start') unless (user_name && !user_name.empty?)
    user = User.find_by_name(user_name)
    return render_with_alert(t('errors.messages.user_not_found'), 'start') unless user
    return render_with_alert(t('errors.messages.user_locked'), 'start') if user.locked
    return render_with_alert(t('errors.messages.email_not_confirmed'), 'start') unless user.confirmed

    token = RestorePasswordToken.create(user, DateTime.now + 10.hours)
    token.save
    UserMailer.restore_password(user, token.code).deliver

    @email = short_email(user.email)
    render_message_view(t('.restore_email_sended', email: @email))
  end

  def change_password
    return unless get_and_validate_token

    @token.expire_date = DateTime.now + 1.hour
    @token.save

    render 'change_password'
  end

  def update_password
    return unless get_and_validate_token

    password = params.require(:user)[:password]
    @user.password = password
    @user.password_confirmation = password

    if (@user.valid?)
      @user.save!
      @token.delete
      return render 'success'
    end

    render 'change_password'
  end

  private

  def get_and_validate_token
    @token_code = params.require(:code)
    @token = RestorePasswordToken.load(@token_code)
    if !@token || @token.expired?
      render_message_view(t('errors.messages.invalid_restore_token'))
      return false
    end
    @user = User.find_by_name(@token.user_name)
    if !@user || @user.email != @token.user_email
      render_message_view(t('errors.messages.invalid_restore_token'))
      return false
    end
    if @user.locked?
      render_message_view(t('errors.messages.user_locked'))
      return false
    end
    return true
  end

  def render_message_view message
    @message = message
    render 'restore_message'
  end

  def render_with_alert alert, view
    flash.now.alert = alert
    render view
  end

  def short_email email
    user, server = email.split('@', 2)
    user[0, [user.length - 3, 0].max] = '***'
    return user + '@' + server
  end

end