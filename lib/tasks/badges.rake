require 'fastercsv'

namespace :badges do
  desc 'Import badge data'
  task :import => :environment do
    tfile = "/tmp/tickets.csv"
    created_count = 0
    FasterCSV.foreach(tfile, :headers => true) do |row|
      # Patron Email,Patron First Name,Patron Last Name,PerformanceID,Performance Name,Ticket Holder,Ticket Reclaimed,Ticket Number
      t_id = "#{row['PerformanceID']}-#{row['Ticket Number']}"

      next if (row['Ticket Reclaimed'].to_i == 1)
      
      t_holder = row['Ticket Holder'] || "Ticket Holder"
      t_fn, t_ln = t_holder.split(' ', 2)
      if t_ln && (t_ln[/^[A-Z]\.?\s(.*?)$/])
        t_ln = $1
      end
      
      b_type = case row['Performance Name']
      when /friday/i
        'Friday Only'
      when /saturday/i
        'Saturday Only'
      when /both/i
        'Both Days'
      when /918/i
        'Party Only'
      end
      
      unless Badge.find_by_ticket_id(t_id)
        badge = Badge.new(:buyer_email => row['Patron Email'],
                :buyer_firstname => row['Patron First Name'],
                :buyer_lastname => row['Patron Last Name'],
                :badge_type => b_type,
                :firstname => t_fn,
                :lastname => t_ln,
                :email => row['Patron Email'],
                :ticket_id => t_id)
        badge.save(:validate => false)
        puts "created #{badge.ticket_id} #{badge.ticketholder}"
        created_count += 1
      end
    end
    puts "Added #{created_count} new badges"
  end   
end

namespace :badges do
  desc 'Import eventbrite data'
  task :import_eventbrite => :environment do
    tfile = "/tmp/attendees.csv"
    created_count = 0
    FasterCSV.foreach(tfile, :headers => true) do |row|
      t_id = "vol-#{row['Attendee #']}"
      #["Home Country", "Home Address 2", "Home Address 1", "Order #", "CC Processing (USD)", "Twitter Username", "Order Type", "Ticket Type", "Last Name", "Date", 
      #"Company", "Talk to Me About (will appear on badge; 3 words only):", "Home Zip", "Home City", "QTY", "Attendee #", "Eventbrite Fees (USD)", "Fees Paid (USD)",
      #"Job Title", "Home State", "Attendee Status", "Group", "Date Attending", "Email", "T-shirt size (unisex):", "Total Paid (USD)", "First Name"]
      unless Badge.find_by_ticket_id(t_id)
        badge = Badge.new(:buyer_email => row['Email'],
                :buyer_firstname => row['First Name'],
                :buyer_lastname => row['Last Name'],
                :badge_type => 'Volunteer',
                :firstname => row['First Name'],
                :lastname => row['Last Name'],
                :email => row['Email'],
                :about => row['Talk to Me About (will appear on badge; 3 words only):'],
                :twitter_handle => row['Twitter Username'],
                :company => row['Company'],
                :title => row['Job Title'],
                :ticket_id => t_id)
        badge.save(:validate => false)        
        puts "created #{t_id} #{badge.ticketholder}"
        created_count += 1
      end
    end
    puts "Added #{created_count} new badges"
  end

  desc "Remind people"
  task :nag_email => :environment do
    Badge.needs_update.each do |badge|
      badge.send_email
    end
  end

  desc "Notify people"
  task :notify_email => :environment do
    Badge.never_emailed.each do |badge|
      badge.send_email
    end
  end
  
  desc "Export nag list"
  task :nag_list => :environment do
    Badge.needs_update.each do |b|
      line = [b.buyer_firstname || b.firstname, b.firstname,b.lastname,b.email,b.key]
      puts FasterCSV.generate_line(line)
    end
  end
  
  desc "Export batch"
  task :batch => :environment do
    batch = Badge.maximum(:batch) || 0
    batch += 1
    puts "next batch is #{batch}"
    # Badge.update_all("batch=#{batch}", ['approved_at < ? AND batch IS NULL', 1.hour.ago])
    Badge.update_all("batch=#{batch}", 'batch IS NULL')
    Badge.where("batch=#{batch}").each do |b|
      b.export
    end    
  end
  
  desc "Remind team"
  task :team_email => :environment do
    Badge.team.each do |b|
      msg = BadgeMailer.volunteer_reminder(b)
      msg.deliver
    end
  end

  desc "Remind speakers"
  task :speaker_email => :environment do
    Badge.speakers.each do |b|
      msg = BadgeMailer.speaker_reminder(b)
      puts "To: #{msg.to} Subject: #{msg.subject}"
      msg.deliver
    end
  end
  
  desc "Remind attendees - Friday"
  task :friday_email => :environment do
    Badge.friday.each do |b|
      msg = BadgeMailer.friday_reminder(b)
      puts "To: #{msg.to} Subject: #{msg.subject}"
      msg.deliver
    end
  end

  desc "Remind attendees - Saturday"
  task :saturday_email => :environment do
    Badge.saturday.each do |b|
      msg = BadgeMailer.saturday_reminder(b)
      puts "To: #{msg.to} Subject: #{msg.subject}"
      msg.deliver
    end
  end

  desc "Wrap Email - Survey"
  task :wrap_email => :environment do
    Badge.all.each do |b|
      msg = BadgeMailer.wrap_email(b)
      puts "To: #{msg.to} Subject: #{msg.subject}"
      msg.deliver
    end
  end

  desc "FB Email - Survey"
  task :fb_email => :environment do
    Badge.all.each do |b|
      msg = BadgeMailer.fb_email(b)
      puts "To: #{msg.to} Subject: #{msg.subject}"
      msg.deliver
    end
  end
  
  desc "Mail List"
  task :mail_list => :environment do
    Badge.all.each do |b|
      line = [b.buyer_firstname || b.firstname, b.firstname,b.lastname,b.email,b.key]
      puts FasterCSV.generate_line(line)
    end
  end
    
end


