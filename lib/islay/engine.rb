module Islay
  class Engine < ::Rails::Engine
    # Explicitly require the ActivityLog to avoid having it reloaded in dev.
    require File.expand_path("../../../app/models/activity_log", __FILE__)

    # Explicitly load the asset processor classes, for the same reason as above.
    Dir.glob(File.expand_path("../../app/asset_management/*_processor.rb", __FILE__)).each do |p|
      require p
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

    # Returns the nav entries defined across all the extensions. This pulls the
    # entries from the navigation module and orders them by priority. 
    #
    # @return Hash
    def self.nav_entries
      @@nav_entries ||= begin
        sorted = Islay::Navigation.sections.sort {|x, y| x.last[:priority] <=> y.last[:priority]}
        Hash[*sorted.flatten(1)]
      end
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
  end
end
