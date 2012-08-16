module Islay
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("../../app/uploaders", __FILE__)
    config.autoload_paths << File.expand_path("../../app/queries", __FILE__)
    config.autoload_paths << File.expand_path("../../app/asset_management", __FILE__)

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :test_unit
    end

    initializer "islay.sprockets" do
      Islay::Sprockets.configure(Rails.application)
    end

    def self.extensions
      @@extensions ||= Extensions.new
      yield(@@extensions) if block_given?
      @@extensions
    end
  end
end
