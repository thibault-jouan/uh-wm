require File.expand_path('../lib/uh/wm/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'uh-wm'
  s.version     = Uh::WM::VERSION.dup
  s.summary     = 'minimalistic tiling and stacking X window manager'
  s.description = <<-eoh
  uhwm is a minimalistic tiling and stacking window manager for X. It
shares some similarities with dwm and wmii, but is written in ruby so
you can configure and extend features directly with ruby code.
  eoh
  s.license     = 'BSD-3-Clause'
  s.homepage    = 'https://rubygems.org/gems/uh-wm'

  s.authors     = 'Thibault Jouan'
  s.email       = 'tj@a13.fr'

  s.files       = `git ls-files lib`.split $/
  s.executable  = 'uhwm'
  s.extra_rdoc_files = %w[README.md]

  s.add_dependency 'baf',       '~> 0.14'
  s.add_dependency 'rb-kqueue', '~> 0.2', '>= 0.2.4'
  s.add_dependency 'uh',        '~> 2.1'
  s.add_dependency 'uh-layout', '~> 0.4', '>= 0.4.2'

  s.add_development_dependency 'rake',        '~> 10'
  s.add_development_dependency 'baf-testing', '~> 0.0'
end
