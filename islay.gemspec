$:.push File.expand_path("../lib", __FILE__)

require "islay/version"

Gem::Specification.new do |s|
  s.name        = "islay"
  s.version     = Islay::VERSION
  s.authors     = ["Luke Sutton", "Ben Hull"]
  s.email       = ["lukeandben@spookandpuff.com"]
  s.homepage    = "http://spookandpuff.com"
  s.summary     = "A Rails engine for website back-ends."
  s.description = %{
    This is a specialised engine used by Spook and Puff for bootstrapping
    websites that need an administration back-end. It is intended to take the
    place of a generic CMS. Instead it provides authentication, asset management,
    admin styles etc., but no 'content management'.

    Instead, any apps using this engine are expected to implement their own
    management logic.
  }

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails",                         "~> 5.2.2.1"
  s.add_dependency 'rails-observers',               "~> 0.1.5"
  s.add_dependency 'cells-rails',                   '~> 0.0.9'
  s.add_dependency "devise",                        "~> 4.6.1"
  s.add_dependency "devise_invitable",              "~> 2.0.0"
  s.add_dependency 'cancancan',                     '~> 2.2'
  s.add_dependency "responders",                    "~> 2.4.0"
  s.add_dependency "simple_form",                   "~> 4.0.1"
  s.add_dependency 'hamlit-rails',                  '~> 0.2.0'
  s.add_dependency 'cells-hamlit',                  '~> 0.2.0'
  s.add_dependency "sass-rails",                    "~> 5.0.7"
  s.add_dependency "compass-rails",                 "~> 3.1.0"
  s.add_dependency "pg",                            "~> 0.18.1"
  s.add_dependency "pg_search",                     "~> 0.7.0"
  s.add_dependency 'friendly_id',                   "~> 5.2.1"
  s.add_dependency "inherited_resources",           "~> 1.8.0"
  s.add_dependency "rmagick",                       "~> 2.16.0"
  s.add_dependency "mime-types",                    '~> 3.2', '>= 3.2.2'
  s.add_dependency "fog-aws",                       "~> 1.4.1"
  s.add_dependency "girl_friday",                   "~> 0.9.7"
  s.add_dependency "streamio-ffmpeg",               "~> 0.8.5"
  s.add_dependency "zipruby",                       "~> 0.3.6"
  s.add_dependency "jquery-rails",                  "~> 4.3.3"
  s.add_dependency "jsonify-rails",                 "~> 0.3.2"
  s.add_dependency "kaminari",                      "~> 1.1.1"
  s.add_dependency 'rdiscount',                     '~> 1.6.8'
  s.add_dependency "acts_as_list",                  "~> 0.1.8"
  s.add_dependency "premailer",                     "~> 1.11.1"
  s.add_dependency 'draper',                        '~> 3.0.1'
  s.add_dependency 'bootsnap',                      '~> 1.3', '>= 1.3.1'
  s.add_dependency 'sprockets-rails',               '~> 3.2', '>= 3.2.1'

  s.add_development_dependency 'listen'
end
