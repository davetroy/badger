require 'fastercsv'

namespace :badges do
  desc 'Import badge data'
  task :import => :environment do
    tfile = "/tmp/tickets.csv"
    FasterCSV.foreach(tfile) do |row|
      # Patron Email,Patron First Name,Patron Last Name,PerformanceID,Performance Name,Ticket Holder,Ticket Reclaimed,Ticket Number
      b_email, b_fn, b_ln, p_id, p_name, t_holder, reclaimed, t_id = row
      t_id = "#{p_id}-#{t_id}"
      next unless t_id > 0

      reclaimed = (reclaimed.to_i == 1)
      next b_email if reclaimed
      
      t_holder ||= "Ticket Holder"
      t_fn, t_ln = t_holder.split(' ', 2)
      
      badge = Badge.find_or_create_by_ticket_id(:buyer_email => b_email,
                :buyer_firstname => b_fn,
                :buyer_lastname => b_ln,
                :badge_type => p_name,
                :firstname => t_fn,
                :lastname => t_ln,
                :email => b_email,
                :ticket_id => t_id)
      p badge
    end    
  end
      
end