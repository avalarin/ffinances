class UserMailer < BaseMailer

  def success_registration user
    @confirmation_url = confirm_account_url code: user.confirmation_code
    mail to: user.email, subject: t('.mail_subject', app_name: Settings.app_name)
  end

  def email_confirmation user
    @confirmation_url = confirm_account_url code: user.confirmation_code
    mail to: user.email, subject: t('.mail_subject', app_name: Settings.app_name)
  end

end
