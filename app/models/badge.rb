class Badge < ActiveRecord::Base
  attr_accessible :about, :approved_at, :badge_type, :buyer_email, :buyer_firstname, :buyer_lastname, :company, :email, :firstname, :key, :lastname, :ticket_id, :title, :twitter_handle, :vegetarian

  before_create { |record| record.key = Digest::MD5.hexdigest("#{ticket_id}#{buyer_email}#{buyer_firstname}#{buyer_lastname}#{id}") }
  before_save { |record| record.twitter_handle = record.twitter_handle.gsub('@', '') }
  
  
  def pass_name
    if self.badge_type[/both/i]
      "2-Day Pass"
    elsif self.badge_type[/friday/i]
      "Friday Only"
    elsif self.badge_type[/saturday/i]
      "Saturday Only"
    elsif self.badge_type[/918/i]
      "Party Only"
    end
  end
end
