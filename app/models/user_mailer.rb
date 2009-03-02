class UserMailer < ActionMailer::Base

  def signup(user, domain, redirect_path, sent_at = Time.now)
    @subject    = I18n.t "site.user_mailer.signup.beast_welcome"
    @body       = {:user => user, :domain => domain, :redirect_path => redirect_path}
    @recipients = user.email
    @from       = 'beast@' + domain.split(":").first
    @sent_on    = sent_at
    @headers    = {}
  end
  
end