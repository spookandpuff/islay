module Islay
  class Engine < ::Rails::Engine
    isolate_namespace Islay

    config.autoload_paths << File.expand_path("../../app/uploaders", __FILE__)

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :test_unit
    end
  end
end
