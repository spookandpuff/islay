namespace :islay do
  namespace :db do
    desc "Loads in seed data for bootstrapping a fresh Islay app."
    task :seed => :environment do
      Islay::Engine.load_seed
    end

    desc "Drop and recreates the DB and seeds it with data"
    task :bootstrap => :environment do
      FileUtils.rm_rf(Rails.root + 'db/migrations')

      Rake::Task['islay_engine:install:migrations'].invoke

      Islay::Engine.extensions.entries.each_pair do |name, e|
        Rake::Task["#{name}_engine:install:migrations"].invoke
      end

      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke

      user = User.create!(
        :name => 'Administrator',
        :email => 'admin@admin.com',
        :password => 'password'
      )

      require 'islay/spec'

      Islay::Engine.extensions.entries.each_pair do |name, e|
        Rake::Task["#{name}:db:seed"].invoke
      end
    end
  end
end
