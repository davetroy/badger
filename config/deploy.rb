set :application, "badger"
set :repository,  "git://github.com/davetroy/badger.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache
set :keep_releases, 3

role :web, '66.159.72.200'
role :db, '66.159.72.200'
set :user, application
set :use_sudo, false
set :deploy_to, "/home/#{application}"

namespace :deploy do
   task :restart, :roles => :web, :except => { :no_release => true } do
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

namespace :db do
  desc "Initialize database"
  task :reset do
    run("cd #{deploy_to}/current && /usr/bin/env rake db:reset RAILS_ENV=production")
  end

  desc "Load database from files"
  task :load do
    run("cd #{deploy_to}/current && /usr/bin/env rake badges:import RAILS_ENV=production")
    run("cd #{deploy_to}/current && /usr/bin/env rake badges:import_eventbrite RAILS_ENV=production")
  end
  
  desc "Upload data files to server"
  task :update do
    sfile = "/Users/davetroy/Downloads/Tickets.csv"
    upload(sfile, "/tmp/tickets.csv")
    File.rename(sfile, "/tmp/tickets.csv")
    
    upload("/tmp/attendees.csv", "/tmp/attendees.csv")
  end
end

namespace :production do
  desc "Run a rake task on production"
  task :rake do
    run("cd #{deploy_to}/current && /usr/bin/env rake #{ENV['TASK']} RAILS_ENV=production")
  end
end

