# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mailtest/version'

Gem::Specification.new do |spec|
  spec.name          = 'mailtest'
  spec.version       = Mailtest::VERSION
  spec.authors       = ['Peter Hoeg']
  spec.email         = ['peter@hoeg.com']

  spec.summary       = 'Generate a test email to a list of receivers.'
  spec.description   = 'Helps when doing mass email changes or migrations\
 where you need to verify that everything is set up correctly.'
  spec.homepage      = 'https://github.com/peterhoeg/mailtest'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'mail'
  spec.add_dependency 'main'
  spec.add_dependency 'awesome_print'
  spec.add_dependency 'progress_bar'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'random-word'
end
