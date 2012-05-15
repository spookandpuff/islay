namespace :islay do
  namespace :db do
    desc "Loads in seed data for bootstrapping a fresh Islay app."
    task :seed => :environment do
      Islay::Engine.load_seed
    end
  end
end
