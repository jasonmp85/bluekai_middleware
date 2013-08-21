# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'bluekai_middleware/version'

Gem::Specification.new do |s|
  s.name        = 'bluekai_middleware'
  s.version     = BlueKaiMiddleware::VERSION
  s.authors     = ['Jason Petersen']
  s.email       = ['jpetersen@bluekai.com']
  s.license     = 'Copyright (c) 2012 Blue Kai, Inc.'
  s.homepage    = 'http://bluekai.com/'
  s.summary     = %q{Common code for interacting with BlueKai services}
  s.description = %q{Includes Faraday middlewares, log formatters, and signing algorithms useful for any user of BlueKai services}

  # Force everyone to at least 1.9.3
  s.required_ruby_version = '~> 1.9.3'

  s.files = Dir['{lib}/**/*'] + ['CHANGELOG.md', 'README.md']
  s.test_files = Dir['spec/**/*_spec.rb']

  s.add_dependency 'activesupport', '~> 3.1'
  s.add_dependency 'faraday',       '>= 0.7.6', '< 0.9.0'
  s.add_dependency 'rack',          '~> 1.3'

  s.add_development_dependency 'appraisal',       '~> 0.5.2'
  s.add_development_dependency 'ci_reporter',     '~> 1.7.0'
  s.add_development_dependency 'rdiscount',       '~> 1.6.8'
  s.add_development_dependency 'rake',            '~> 0.9.2.2'
  s.add_development_dependency 'rspec',           '~> 2.11.0'
  s.add_development_dependency 'simplecov',       '~> 0.7.1'
  s.add_development_dependency 'simplecov-rcov',  '~> 0.2.3'
  s.add_development_dependency 'yard',            '~> 0.8.2.1'
end
