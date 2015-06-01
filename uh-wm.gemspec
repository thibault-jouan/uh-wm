require File.expand_path('../lib/uh/wm/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'uh-wm'
  s.version     = Uh::WM::VERSION.dup
  s.summary     = 'minimalistic tiling and stacking X window manager'
  s.description = <<-eoh
  uhwm is a minimalistic tiling and stacking window manager for X. It
shares some similarities with dwm and wmii, but is written in ruby so
you can configure and extend features directly with ruby code.

  The layout strategy is interchangeable, the default one being the
`uh-layout` ruby gem. A layout is a simple ruby object responding to
specific messages, so it's easy to write your own layout.

  Main features:

  * Xinerama support;
  * different adapters for event handling: blocking, multiplexing
    with `select()` or `kqueue()`;
  * configuration with a run control file;
  * key bindings with user defined code as callback;
  * configurable modifier key;
  * user-defined layout strategies;
  * external program execution;
  * no re-parenting (therefore, no window decoration either);
  * no grabbing of the modifier key alone;
  * no mouse event handling;
  * no EWMH support;
  * very limited ICCCM support.
  eoh
  s.license     = 'BSD-3-Clause'
  s.homepage    = 'https://rubygems.org/gems/uh-wm'

  s.authors     = 'Thibault Jouan'
  s.email       = 'tj@a13.fr'

  s.files       = `git ls-files lib`.split $/
  s.executable  = 'uhwm'
  s.extra_rdoc_files = %w[README.md]

  s.add_dependency 'rb-kqueue', '~> 0.2.4'
  s.add_dependency 'uh',        '2.0.2'
  s.add_dependency 'uh-layout', '~> 0.4.2'

  s.add_development_dependency 'aruba',     '~> 0.6'
  s.add_development_dependency 'cucumber',  '~> 2.0'
  s.add_development_dependency 'headless',  '~> 1.0'
  s.add_development_dependency 'rake',      '~> 10.4'
  s.add_development_dependency 'rspec',     '~> 3.2'
end
