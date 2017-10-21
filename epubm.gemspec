# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epubm/version'

Gem::Specification.new do |spec|
  spec.name          = 'epubm'
  spec.version       = Epubm::VERSION
  spec.authors       = ['Keita Urashima']
  spec.email         = ['ursm@ursm.jp']

  spec.summary       = %q{EPUB metadata editor}
  spec.homepage      = 'https://github.com/ursm/epubm'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rubyzip'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
