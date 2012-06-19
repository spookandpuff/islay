require 'rspec/rails'
require 'capybara/rspec'
require 'machinist/active_record'
require 'ffaker'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.default_driver = :poltergeist

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

roots = [Islay::Engine.root, *Islay::Engine.extensions.roots, Rails.root]
roots.each do |r|
  Dir[r + 'spec/blueprints/*.rb'].each {|f| require f}
end

Thread.current[:current_user] = User.first || User.make!

def pick(model)
  model.order('RANDOM()').first
end

