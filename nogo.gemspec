# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nogo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andy Ogzewalla"]
  gem.email         = ["andyogzewalla@gmail.com"]
  gem.description   = %q{A library that lets you know when your code touches your database}
  gem.summary       = %q{A library that lets you know when your code touches your database}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "nogo"
  gem.require_paths = ["lib"]
  gem.version       = NoGo::VERSION

  gem.add_dependency 'rspec', '~> 2.7.0'
  gem.add_dependency 'activerecord', '~> 3.0'
  gem.add_development_dependency 'rspec', '~> 2.7.0'
  gem.add_development_dependency 'activerecord', '~> 3.0'
end
