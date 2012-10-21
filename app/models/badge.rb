class Badge < ActiveRecord::Base
  attr_accessible :about, :approved_at, :badge_type, :buyer_email, :buyer_firstname, :buyer_lastname, :company, :email, :firstname, :key, :lastname, :ticket_id, :title, :twitter_handle, :vegetarian

  before_create { |record| record.key = Digest::MD5.hexdigest("#{ticket_id}#{buyer_email}#{buyer_firstname}#{buyer_lastname}#{firstname}#{lastname}#{company}#{email}#{id}"); record.ticket_id ||= "internal-#{Time.now.to_f}" }
  before_save { |record| record.twitter_handle = record.twitter_handle.gsub('@', '') unless record.twitter_handle.nil? }
  
  scope :needs_update, { :conditions => 'emailed_at IS NULL' }
  
  validates_presence_of :firstname, :lastname, :email
  
  def pass_name
    case self.badge_type
      when /(both|volunteer|speaker|staff)/i
        "2-Day Pass"
      when /friday/i
        "Friday Only"
      when /saturday/i
        "Saturday Only"
      when /party/i
        "Party Only"
      else
        "Guest"
    end
  end
  
  def buyer
    "#{buyer_firstname} #{buyer_lastname}"
  end
  
  def ticketholder
    "#{firstname} #{lastname}"
  end
  
  def badge_class
    case self.badge_type
    when /volunteer/i
      "Volunteer"
    when /staff/i
      "Staff"
    when /speaker/i
      "Speaker"
    when /party/i
      "Party"
    else
      "Attendee"
    end
  end
  
  def bought_by_third_party?
    buyer!=ticketholder
  end
  
  def full_email
    "#{buyer} <#{email}>"
  end
  
  def to_param
    key
  end
  
end
