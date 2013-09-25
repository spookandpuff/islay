module Islay
  class Engine < ::Rails::Engine
    # Explicitly require the ActivityLog to avoid having it reloaded in dev.
    require File.expand_path("../../../app/models/activity_log", __FILE__)

    config.autoload_paths << File.expand_path("../../app/queries", __FILE__)
    config.autoload_paths << File.expand_path("../../app/asset_management", __FILE__)

    unless File.basename($0) == 'rake'
      config.active_record.observers = :searchable_observer
    end

    # Remove the stupid div.field_with_errors wrapper Rails pollutes forms with.
    ActionView::Base.field_error_proc = lambda {|tag, obj| tag}

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :test_unit
    end

    initializer "islay.sprockets" do
      Islay::Sprockets.configure(Rails.application)
    end

    def self.content
      @@pages ||= Pages.new
      yield(@@pages) if block_given?
      @@pages
    end

    def self.extensions
      @@extensions ||= Extensions.new
      yield(@@extensions) if block_given?
      @@extensions
    end

    def self.searches
      @@searches ||= Searches.new
      yield(@@searches) if block_given?
      @@searches
    end
  end
end
