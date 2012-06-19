$:.push File.expand_path("../lib", __FILE__)

require "islay/version"

Gem::Specification.new do |s|
  s.name        = "islay"
  s.version     = Islay::VERSION
  s.authors     = ["Luke Sutton", "Ben Hull"]
  s.email       = ["lukeandben@spookandpuff.com"]
  s.homepage    = "http://spookandpuff.com"
  s.summary     = "A Rails engine for website back-ends."
  s.description = "A Rails engine for website back-ends."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails",                         "~> 3.2.6"
  s.add_dependency "mixable_engines",               "~> 0.1.1"
  s.add_dependency "devise",                        "~> 2.0.4"
  s.add_dependency "simple_form",                   "~> 2.0.2"
  s.add_dependency "haml",                          "~> 3.1.5"
  s.add_dependency "sass-rails",                    "~> 3.2.5"
  s.add_dependency "compass-rails",                 "~> 1.0.1"
  s.add_dependency "pg",                            "~> 0.13.2"
  s.add_dependency "schema_plus",                   "~> 0.4.0"
  s.add_dependency "activerecord-postgres-hstore",  "~> 0.3.0"
  s.add_dependency "inherited_resources",           "~> 1.3.1"
  s.add_dependency "carrierwave",                   "~> 0.6.2"
  s.add_dependency "carrierwave_backgrounder",      "~> 0.0.6"
  s.add_dependency "girl_friday",                   "~> 0.9.7"
  s.add_dependency "rmagick",                       "~> 2.13.1"
  s.add_dependency "mime-types",                    "~> 1.18"
  s.add_dependency "streamio-ffmpeg",               "~> 0.8.5"
  s.add_dependency "zipruby",                       "~> 0.3.6"
  s.add_dependency "jquery-rails",                  "~> 2.0.2"
  s.add_dependency "jsonify-rails",                 "~> 0.3.2"

  # Strictly speaking, these are dev dependencies, but we need to ensure it is
  # installed when using other Islay engines.
  s.add_dependency "machinist",     "~> 2.0"
  s.add_dependency "ffaker",        "~> 1.14.0"
  s.add_dependency "capybara",      "~> 1.1.2"
  s.add_dependency "poltergeist",   "~> 0.6.0"
end
