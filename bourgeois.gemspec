# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bourgeois/version'

Gem::Specification.new do |spec|
  spec.name          = 'bourgeois'
  spec.version       = Bourgeois::VERSION
  spec.authors       = ['Rémi Prévost']
  spec.email         = ['rprevost@mirego.com']
  spec.description   = 'Bourgeois is a Ruby library that makes using presenters a very simple thing.'
  spec.summary       = 'Bourgeois is a Ruby library that makes using presenters a very simple thing.'
  spec.homepage      = 'https://github.com/mirego/bourgeois'
  spec.license       = 'BSD 3-Clause'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activemodel', '>= 3.0.0'
  spec.add_dependency 'actionpack', '>= 3.0.0'

  spec.add_development_dependency 'rspec', '~> 2.13'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
