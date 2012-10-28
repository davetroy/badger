class BadgeMailer < ActionMailer::Base
  default :from => "TEDxMidAtlantic Applications <applications@tedxmidatlantic.com>"
 
  def please_edit(badge)
    @badge = badge
    mail(:to => @badge.full_email,
         :subject => "[TEDxMidAtlantic] Important: Please create a badge for #{badge.ticketholder}",
         'X-Priority' => '1')
  end
  
  def volunteer_reminder(badge)
    @badge = badge
    mail(:from => "TEDxMidAtlantic Team <contact@tedxmidatlantic.com>",
         :to => @badge.full_email,
         :subject => "[TEDxMidAtlantic] Reminder: Staff and Volunteer mandatory meeting 5pm TODAY")
  end

  def speaker_reminder(badge)
    @badge = badge
    mail(:from => "TEDxMidAtlantic Team <contact@tedxmidatlantic.com>",
         :to => @badge.full_email,
         :subject => "[TEDxMidAtlantic Speakers] Rundown for Thursday, Friday, and Saturday")
  end

  def friday_reminder(badge)
    @badge = badge
    mail(:from => "TEDxMidAtlantic Team <contact@tedxmidatlantic.com>",
         :to => @badge.full_email,
         :subject => "[TEDxMidAtlantic] Friday: What you need to know")
  end

  def saturday_reminder(badge)
    @badge = badge
    mail(:from => "TEDxMidAtlantic Team <contact@tedxmidatlantic.com>",
         :to => @badge.full_email,
         :subject => "[TEDxMidAtlantic] Saturday: What you need to know")
  end
  
  def wrap_email(badge)
    @badge = badge
    mail(:from => "TEDxMidAtlantic Team <contact@tedxmidatlantic.com>",
         :to => @badge.full_email,
         :subject => "[TEDxMidAtlantic] It's a wrap! Please tell us what you thought of TEDxMidAtlantic 2012")
  end
    
  
end