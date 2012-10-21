set :application, "badger"
set :repository,  "git://github.com/davetroy/badger.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache
set :keep_releases, 3

role :web, '66.159.72.200'
set :user, application
set :use_sudo, false
set :deploy_to, "/home/#{application}"

namespace :badges do
  desc "Push new badges to production"
  task :update do
    upload("/Users/davetroy/Downloads/Tickets.csv", "#{deploy_to}/tickets.csv")
    run("cd #{deploy_to}/current && /usr/bin/env rake badges:import RAILS_ENV=production")
  end
end