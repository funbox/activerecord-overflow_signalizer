# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/overflow_signalizer/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-overflow_signalizer'
  spec.version       = ActiveRecord::OverflowSignalizer::VERSION
  spec.authors       = ['v.promzelev']
  spec.email         = ['v.promzelev@fun-box.ru']

  spec.summary       = 'Signalize when some primary key overflow soon.'
  spec.description   = 'Signalize when some primary key overflow soon.'
  spec.homepage      = 'https://github.com/funbox/activerecord-overflow_signalizer'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # spec.add_runtime_dependency 'activerecord', '~> 3.2'
  spec.add_runtime_dependency 'pg', '~> 0.20'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'appraisal', '~> 2.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'pry'
end
