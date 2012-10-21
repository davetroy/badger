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
end

namespace :badges do
  desc "Email people"
  task :email => :environment do
    count=0
    Badge.needs_update.each do |badge|
      msg = BadgeMailer.please_edit(badge)
      puts "To: #{msg.to} Subject: #{msg.subject}"
      begin
        msg.deliver
        badge.emailed_at = Time.now
        badge.save(:validate => false)
      rescue => e
        puts e.message
        sleep 60
        retry
      end
      count += 1
      break if count>20
    end
  end
end