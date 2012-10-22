class Badge < ActiveRecord::Base
  attr_accessible :about, :approved_at, :badge_type, :buyer_email, :buyer_firstname, :buyer_lastname, :company, :email, :firstname, :key, :lastname, :ticket_id, :title, :twitter_handle, :vegetarian

  before_create { |record| record.key = Digest::MD5.hexdigest("#{ticket_id}#{buyer_email}#{buyer_firstname}#{buyer_lastname}#{firstname}#{lastname}#{company}#{email}#{id}"); record.ticket_id ||= "internal-#{Time.now.to_f}" }
  before_save { |record| record.twitter_handle = record.twitter_handle.gsub('@', '') unless record.twitter_handle.nil? }
  
  scope :needs_update, { :conditions => 'emailed_at IS NOT NULL AND approved_at IS NULL' }
  scope :approved, { :conditions => 'approved_at IS NOT NULL' }
  scope :never_emailed, { :conditions => 'emailed_at IS NULL' }
  
  validates_presence_of :firstname, :lastname, :email
  
  def pass_name
    case self.badge_type
      when /(both|volunteer|speaker|staff|sponsor)/i
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
    when /sponsor/i
      "Sponsor"
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
  
  def send_email
    msg = BadgeMailer.please_edit(self)
    puts "To: #{msg.to} Subject: #{msg.subject}"
    begin
      msg.deliver
      self.emailed_at = Time.now
      self.save(:validate => false)
    rescue => e
      puts e.message
    end
  end
  
  def friday?
    !badge_type[/saturday/i.freeze]
  end
  
  def saturday?
    !badge_type[/friday/i.freeze]
  end
  
  def to_param
    key
  end
  
  def to_csv
    FasterCSV.generate_line([ticket_id, firstname, lastname, title, company, about, twitter_handle, badge_type])
  end
  
  def export_dir
    @export_dir ||= "/home/badger/csv/#{self.batch}"
    Dir.mkdir(@export_dir) unless File.exist?(@export_dir)
    @export_dir
  end
  
  def filename
    if self.about.blank?
      "#{export_dir}/#{badge_type.parameterize}.csv"
    else
      "#{export_dir}/#{badge_type.parameterize}-about.csv"      
    end
  end
  
  def export
    File.open(filename, 'a') do |f|
      f.write self.to_csv
    end
  end 
   
end
