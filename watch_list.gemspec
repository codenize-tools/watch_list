# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'watch_list/version'

Gem::Specification.new do |spec|
  spec.name          = 'watch_list'
  spec.version       = WatchList::VERSION
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sgwr_dts@yahoo.co.jp']
  spec.summary       = %q{watch_list is a tool to manage Uptime Robot.}
  spec.description   = %q{watch_list is a tool to manage Uptime Robot. It defines Uptime Robot monitors using Ruby DSL, and updates monitors according to DSL.}
  spec.homepage      = 'http://watch_list.codenize.tools/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'uptimerobot', '>= 0.1.6'
  spec.add_dependency 'term-ansicolor'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
end

## Similar tools
* [Codenize.tools](http://codenize.tools/)
