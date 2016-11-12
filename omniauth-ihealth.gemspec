# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-ihealth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'omniauth-oauth2', '~> 1.0'
  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'

  gem.authors       = ['Hunter Spinks', 'Artur Karbone', 'Victor Vargas', 'Martin Streicher']
  gem.description   = %q{OmniAuth strategy for iHealth.com}
  gem.email         = ['martin.streicher@duke.edu']
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.homepage      = 'https://github.com/dukedigitalhealth/omniauth-ihealth'
  gem.name          = 'omniauth-ihealth'
  gem.require_paths = ['lib']
  gem.summary       = %q{OmniAuth strategy for iHealth.com.}
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version       = OmniAuth::IHealth::VERSION
end
