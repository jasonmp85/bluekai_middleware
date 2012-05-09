# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'bluekai_middleware/version'

Gem::Specification.new do |s|
  s.name        = 'bluekai_middleware'
  s.version     = BluekaiMiddleware::VERSION
  s.authors     = ['Jason Petersen']
  s.email       = ['jpetersen@bluekai.com']
  s.license     = 'Copyright (c) 2012 Blue Kai, Inc.'
  s.homepage    = 'http://bluekai.com/'
  s.summary     = %q{Common code for interacting with BlueKai services}
  s.description = %q{Includes Faraday middlewares, log formatters, and signing algorithms useful for any user of BlueKai services}

  s.rubyforge_project = 'bluekai_middleware'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'active_support', '~> 3.1.3'
end
