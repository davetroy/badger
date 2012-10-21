class BadgeMailer < ActionMailer::Base
  default :from => "TEDxMidAtlantic Applications <applications@tedxmidatlantic.com>"
 
  def please_edit(badge)
    @badge = badge
    mail(:to => @badge.email, :subject => "[TEDxMidAtlantic] Urgent: Please create a badge for #{badge.ticketholder}")
  end
end