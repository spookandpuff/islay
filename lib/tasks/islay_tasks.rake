namespace :islay do
  namespace :db do
    desc "Rebuilds the search term index for each record in the DB."
    task :rebuild_search_index => :environment do
      puts "REBUILDING INDEX"

      Islay::Engine.searches.updates.each do |name, update|
        puts name.to_s.humanize.pluralize

        klass = name.to_s.classify.constantize
        klass.all.each {|r| Search.update_entry(r, name)}
      end
    end

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
