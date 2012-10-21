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

namespace :deploy do
  task :restart do ; end
end
