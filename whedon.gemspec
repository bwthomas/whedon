# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "whedon/version"

Gem::Specification.new do |s|
  s.name        = "whedon"
  s.version     = Whedon::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Mettraux", "Blake Thomas"]
  s.email       = ["jmettraux@gmail.com", "bwthomas@gmail.com"]
  s.homepage    = "https://github.com/bwthomas/whedon"
  s.summary     = %q{Parses cron lines}
  s.description = %q{Parses cron lines into a Schedule instance that can be queried.}
  s.license     = 'MIT'

  s.rubyforge_project = "whedon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'tzinfo'

  s.add_development_dependency 'rspec', '~>3.5.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
end
