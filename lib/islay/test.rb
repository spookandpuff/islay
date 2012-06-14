require 'machinist/active_record'
require 'ffaker'
require 'capybara/rails'
require 'capybara/poltergeist'

# Require all the blue prints across engines
roots = [Islay::Engine.root, *Islay::Engine.extensions.roots, Rails.root]
roots.each do |r|
  Dir[r + 'test/blueprints/*.rb'].each {|f| require f}
end

Thread.current[:current_user] = User.first || User.make!

def pick(model)
  model.order('RANDOM()').first
end

# Capybara configuration
Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  teardown do
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end
