$:.push File.expand_path("../lib", __FILE__)

require "islay/version"

Gem::Specification.new do |s|
  s.name        = "Islay"
  s.version     = Islay::VERSION
  s.authors     = ["Luke Sutton", "Ben Hull"]
  s.email       = ["lukeandben@spookandpuff.com"]
  s.homepage    = "http://spookandpuff.com"
  s.summary     = "A Rails engine for website back-ends."
  s.description = "A Rails engine for website back-ends."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails",         "~> 3.2.3"
  s.add_dependency "devise",        "~> 2.0.4"
  s.add_dependency "simple_form",   "~> 2.0.2"
  s.add_dependency "haml",          "~> 3.1.5"
  s.add_dependency "sass-rails",    "~> 3.2.5"
  s.add_dependency "compass-rails", "~> 1.0.1"

  s.add_development_dependency "machinist", "~> 2.0"
  s.add_development_dependency "sqlite3"
end
