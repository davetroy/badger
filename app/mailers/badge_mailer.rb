class BadgeMailer < ActionMailer::Base
  default :from => "TEDxMidAtlantic Applications <applications@tedxmidatlantic.com>"
 
  def please_edit(badge)
    @badge = badge
    mail(:to => @badge.email,
         :subject => "[TEDxMidAtlantic] Important: Please create a badge for #{badge.ticketholder}"),
         'X-Priority' => '1')
  end
end