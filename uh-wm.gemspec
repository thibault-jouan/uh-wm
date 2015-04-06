require File.expand_path('../lib/uh/wm/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'uh-wm'
  s.version = Uh::WM::VERSION.dup
  s.summary = 'uh window manager'
  s.description = s.name
  s.homepage = 'https://rubygems.org/gems/uh-wm'

  s.authors = 'Thibault Jouan'
  s.email   = 'tj@a13.fr'

  s.files       = `git ls-files`.split $/
  s.test_files  = s.files.grep /\A(spec|features)\//
  s.executables = s.files.grep(/\Abin\//) { |f| File.basename(f) }

  s.add_dependency 'uh', '~> 2.0'
end
