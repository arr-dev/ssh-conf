# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssh-conf/version'

Gem::Specification.new do |gem|
  gem.name          = "ssh-conf"
  gem.version       = Ssh::Config::VERSION
  gem.authors       = ["Nenad Petronijevic"]
  gem.email         = ["set.krag@gmail.com"]
  gem.description   = %q{Displays ssh config for given hosts}
  gem.summary       = %q{Displays ssh config for given hosts, with different output options}
  gem.homepage      = "https://github.com/arr-dev/ssh-conf"

  gem.license       = 'MIT'
  gem.files         = Dir['{bin/*,lib/**/*,spec/**/*}']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency "pry", '~> 0'
end
