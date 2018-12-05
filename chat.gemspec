$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "chat/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "chat"
  s.version     = Chat::VERSION
  s.authors     = ["Yu Song"]
  s.email       = ["bjslxxx@126.com"]
  s.homepage    = "http://www.chat.com"
  s.summary     = "Patient and Provider can chat"
  s.description = "This is a 2-way chat."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1", ">= 5.2.1.1"

  s.add_development_dependency "sqlite3"
end
