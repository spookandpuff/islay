require 'resque/tasks'

task "resque:setup" => :environment do
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

namespace :islay do
  namespace :db do
    desc "Loads in seed data for bootstrapping a fresh Islay app."
    task :seed => :environment do
      Islay::Engine.load_seed
    end

    desc "Drop and recreates the DB and seeds it with data"
    task :bootstrap => :environment do
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke

      user = User.create!(
        :name => 'Administrator',
        :email => 'admin@admin.com',
        :password => 'password'
      )
    end
  end
end
