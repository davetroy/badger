class BadgeMailer < ActionMailer::Base
  default :from => "badges@tedxmidatlantic.com"
 
  def welcome_email(badge)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => badge.email, :subject => "Welcome to My Awesome Site")
  end
end