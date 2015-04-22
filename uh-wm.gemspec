require File.expand_path('../lib/uh/wm/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'uh-wm'
  s.version = Uh::WM::VERSION.dup
  s.summary = 'minimalistic tiling and stacking window manager for X'
  s.description = s.name
  s.license = 'BSD-3-Clause'
  s.homepage = 'https://rubygems.org/gems/uh-wm'

  s.authors = 'Thibault Jouan'
  s.email   = 'tj@a13.fr'

  s.files       = `git ls-files`.split $/
  s.test_files  = s.files.grep /\A(spec|features)\//
  s.executables = s.files.grep(/\Abin\//) { |f| File.basename(f) }

  s.add_dependency 'uh',        '2.0.0.pre2'
  s.add_dependency 'uh-layout', '~> 0.2.2'

  s.add_development_dependency 'aruba',     '~> 0.6'
  s.add_development_dependency 'cucumber',  '~> 2.0'
  s.add_development_dependency 'headless',  '~> 1.0'
  s.add_development_dependency 'rake',      '~> 10.4'
  s.add_development_dependency 'rspec',     '~> 3.2'
end
